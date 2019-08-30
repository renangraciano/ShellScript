#!/bin/bash
#Script for install, upgrade and bundle new or existent installations of Redmine APP.
#Author : Renan Souza
#Contributors : Elliann Marks, Luciano Romao
#Data : 22/08/2019
#Upgrade: 19/08/2019 <renan.souza@endurance.com>
#Bugs : renan.souza@endurance.com
#Updates: 19/08/2019 - Renan Souza

#Changelog
#19/08/2019
#New Updates
#NEW this option installs the last version supported, bundle and register a passenger app
#Update old versions (<4.0.4) to the last version (4.0.4) this option includes backup, new install, and sync data.
#Bundle bundle a new or existent installation

#Colors
VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
AMARELO="\033[1;33m"
RESETCOR="\033[0m"

#Package options
PACKAGE="http://www.redmine.org/releases/redmine-4.0.4.tar.gz"
VERSION="4.0.4"

#Parameters
valueUser=${1} #
valuePath=${2} #
valueType=${3} #
valueDomain=${4} #

#Script Variables
data=$(date +%d%m%Y)

#checks
userCheck=0
typeCheck=0
domainCheck=0
dbCheck=0
dbuserchek=0

logExec="/tmp/HG_RedMiner.log"

SECONDS=0;

_jailshellCheck(){
    if [[ -n $(grep ${valueUser} /etc/passwd | grep -o noshell) ]]
    then
    whmapi1 modifyacct user=${valueUser} HASSHELL=1 2&>1 /dev/null
    fi
}

_userCheck(){
    suser=$(getent passwd ${valueUser})
    if [[ -z $suser ]] || [[ $(echo $suser|cut -d: -f3) -lt '500' ]]
    then
    echo -e "${VERMELHO}[ERROR] :: Invalid User Provided! [CHECK] ${RESETCOR}\n"
    exit 0
    elif whmapi1 accountsummary user=${valueUser} | grep -wq "suspended: 1";
    then
    echo -e "${VERMELHO}[ERROR] :: Suspended User Provided! [CHECK] ${RESETCOR}"
    exit 0
    else
    userCheck=1
    fi
}

_defineWorkDir() {
HomeDir="/home/${valueUser}"
WorkDir="${HomeDir}/${valuePath}"

cd ${HomeDir}

    case $valueType in
    '1')
    RedmineDir="${HomeDir}/${valuePath}/redmine_${data}"
    databaseConfiguration="${RedmineDir}/config/database.yml"
    new_db=$(tr -cd '[:digit:]' < /dev/urandom | fold -w2 | head -n1)
    db="${valueUser}_rmin${new_db}"
    db_user="${valueUser}_rmin${new_db}"
    db_pass="$(openssl rand -base64 8)"
    ;;
    
    '2'|'3')
    OldRedmineDir=$(find ${WorkDir} -maxdepth 3 -type f -name 'database.yml' | sort -n | cut -d/ -f5)
    RedmineDir="${WorkDir}/${OldRedmineDir}"
    OldRedmineVersion=$(head -n10 ${WorkDir}/${OldRedmineDir}/doc/CHANGELOG| cut -d' ' -f3|grep ^v|tr -d 'v')
    databaseConfiguration="${RedmineDir}/config/database.yml"
    BackupDir="${WorkDir}/backup"
    ;;
    '*')
    echo -e "${VERMELHO}[ERROR] :: Define WorkDir error! [CHECK] ${RESETCOR}"
    exit 0
    ;;
    esac
}

_typeCheck(){
    if [[ ${valueType} == "NEW" ]] || [[ ${valueType} == "new" ]]
    then
    valueType="1";
    typeCheck=1
    elif [[ ${valueType} == "UPGRADE" ]] || [[ ${valueType} == "upgrade" ]]
    then
    typeCheck=1
    valueType="2";
    elif [[ ${valueType} == "BUNDLE" ]] || [[ ${valueType} == "bundle" ]]
    then
    typeCheck=1
    valueType="3";
    else
    typeCheck=0
    echo -e "$VERMELHO You must provide a valid type! $RESETCOR"
    exit 0
    fi
}

_domainCheck(){
    if [[ "$(grep ${valueDomain} /etc/trueuserdomains|cut -d: -f2|tr -d ' ')" == "${valueUser}" ]]
    then
    domainCheck=1
    else
    domainCheck=0
    echo -e "${VERMELHO}User ${valueUser} is not a owner this domain ${valueDomain} check ! ${RESETCOR}"
    exit 0
    fi
}

_createPassengerApp(){
    SubdomainApp="redminer"
    VerifyApp=$(cpapi2 --user="${valueUser}" SubDomain listsubdomains regex="${SubdomainApp}.${valueDomain}"|grep -w ${SubdomainApp})
    if [[ -z $VerifyApp ]]
    then
    echo -e "${VERDE}[INFO] :: Registering application [Executing]${RESETCOR}"
    sleep 1
    cpapi2 --user=${valueUser} SubDomain addsubdomain domain=${SubdomainApp} rootdomain=${valueDomain} dir="${RedmineDir##${HomeDir}}" disallowdot=1 2&>1 /dev/null
    uapi --user=${valueUser} PassengerApps register_application name="RedMiner" path="${RedmineDir##${HomeDir}}" domain="${SubdomainApp}.${valueDomain}" deployment_mode="production" 2&>1 /dev/null    
    echo -e "${VERDE}[INFO] :: Registering application - [OK]\n Check app on => ${SubdomainApp}.${valueDomain}${RESETCOR}"
    sleep 1
    else
    echo -e "${VERMELHO}[ERROR] :: Subdomain Already Exists, Register the path manually in the application.${RESETCOR}"
    exit 0
    fi
    }

_usage() {
    echo -e "${VERDE}
    Usage: UpgradeRedmine.sh [USER] [PATH] [TYPE] [DOMAIN]
    
    Types: ${VERMELHO}[CAPS LOCK]${RESETCOR}
    NEW - Fresh Installation
    UPGRADE - Upgrade an Installation
    BUNDLE - Bundle an Installation
    ${RESETCOR}
    ${VERMELHO}
    Examples:
    ./RedMiner.sh snappy rails_apps NEW mydomain
        --- installs a redmine in /home/snappy/rails_apps in snappy account ---
    \n
    ./RedMiner.sh snappy rails_apps UPGRADE mydomain.com
    --- Upgrade a existent redmine to ${VERSION} in path /home/snappy/rails_apps in snappy account ---
        ---- * This option provides backup * ---
    \n
    ./RedMiner.sh snappy rails_apps BUNDLE mydomain.com
        --- Verify if is a valid installation in path /home/snappy/rails_apps and execute bundle and rake commands ---

    ${RESETCOR}"
}

_checkExecution() {
    if [ "$1" != "0" ]
    then
        echo -e "${VERMELHO}[ERROR] :: Check the log in $logExec!${RESETCOR}"
        exit 1
    fi
}

_checkEmailYAML() {
    if [ -f $RedmineDir"/config/email.yml" ]
    then
        echo -e "${VERMELHO}[ERROR] ::
        ==================================================================================================
            If upgrading from version older than 1.2.0, copy your email settings from your config/email.yml 
            into the new config/configuration.yml file that can be created by copying the available 
            configuration.yml.example file.
        ==================================================================================================${RESETCOR}"
        exit 1
    fi
}

_createBackup() {
    if [[ -z ${RedmineDir} ]] || [[ -z $db ]]
    then
    echo -e "${VERMELHO}[ERROR] :: Old RedMine Directory and DB not found on ${WorkDir}, contact an L2 or L3! ${RESETCOR}"
    else
    
        if [[ ! -d ${BackupDir} ]]
        then
        su ${valueUser} -c "mkdir -p ${BackupDir}"
        fi

    echo -e "${VERDE}[INFO] :: Creating Backup File [Executing] ${RESETCOR}"
    sleep 1
    mysqldump $db > $BackupDir/$db.sql
    _checkExecution $?
    chown $valueUser: $BackupDir/$db.sql 1> /dev/null 2> $logExec
    tar -cvzf $BackupDir/upgrade-redmine-$(date +%d-%m-%Y).tar.gz $RedmineDir  1> /dev/null 2> $logExec
    _checkExecution $?
    su ${valueUser} -c "mv ${RedmineDir} ${WorkDir}/redmineOLD"
    _checkExecution $?
    echo -e "${VERDE}[INFO] :: Backup completed! [OK] ${RESETCOR}"
    sleep 1
    fi
}

_syncFiles() {
    RedmineDir="${WorkDir}/redmine_${data}"
    echo -e "${VERDE}[INFO] :: Synchronizing files [Executing]${RESETCOR}"
    if [[ -f "$WorkDir/redmineOLD/config/configuration.yml" ]] 
    then
    su $valueUser -c "cp -p $WorkDir/redmineOLD/config/configuration.yml $RedmineDir/config/ 1> /dev/null 2> $logExec"
    fi

    if [[ -f "$WorkDir/redmineOLD/config/database.yml" ]] 
    then
    su $valueUser -c "mv $WorkDir/redmineOLD/config/database.yml $RedmineDir/config/ 1> /dev/null 2> $logExec"
    _checkExecution $?
    #not backup mysql in different versions
    mysql $db < "${WorkDir}/backup/$db.sql"
    _checkExecution $?
    fi
    if [[ -d "$WorkDir/redmineOLD/vendor/plugins/" ]] || [[ -d "$WorkDir/redmineOLD/files/" ]]
    then
    su $valueUser -c "rsync -avzr $WorkDir/redmineOLD/vendor/plugins/ $RedmineDir/vendor/plugins/ 1> /dev/null 2> $logExec"    
    su $valueUser -c "rsync -avzr $WorkDir/redmineOLD/files/ $RedmineDir/files/ 1> /dev/null 2> $logExec"
    fi
    echo -e "${VERDE}[INFO] :: Synchronizing files [OK]${RESETCOR}"
}

_bundleInstall() {
    echo -e "${VERDE}[INFO] :: Executing bundle install [Executing]${RESETCOR}"
    
    if [ -f $RedmineDir/Gemfile.lock ]
    then   
        rm -f $RedmineDir/Gemfile.lock
        _checkExecution $?
    fi
    
    cd $RedmineDir && scl enable ea-ruby24 'bundle install --without development test rmagick --path vendor/bundle' 1> /dev/null 2> $logExec
        _checkExecution $?
        chown -R $valueUser.$valueUser $RedmineDir
    echo -e "${VERDE}[INFO] :: Executing bundle install [OK]${RESETCOR}"
}

_bundleExec() {
    echo -e "${VERDE}[INFO] :: Executing bundle exec [Executing]${RESETCOR}"
    su $valueUser -c "cd $RedmineDir && scl enable ea-ruby24 'bundle exec rake generate_secret_token' 1> /dev/null 2> $logExec"
    _checkExecution $?
    su $valueUser -c "cd $RedmineDir && scl enable ea-ruby24 'bundle exec rake db:migrate RAILS_ENV=production' 1> /dev/null 2> $logExec"
    _checkExecution $?
    su $valueUser -c "cd $RedmineDir && scl enable ea-ruby24 'bundle exec rake redmine:plugins:migrate RAILS_ENV=production' 1> /dev/null 2> $logExec"
    _checkExecution $?
    su $valueUser -c "cd $RedmineDir && scl enable ea-ruby24 'bundle exec rake tmp:cache:clear RAILS_ENV=production' 1> /dev/null 2> $logExec"
    _checkExecution $?
    echo -e "${VERDE}[INFO] ::  Executing bundle exec [OK]${RESETCOR}"
}

_createDB(){
    #new    
    checkdb=$(mysqlshow|grep -w $db)
    checkdb_user=$(whmapi1 list_database_users 2> /dev/null| grep -w $db_user)

    if [[ -z $checkdb ]]
    then
    uapi --user="${valueUser}" Mysql create_database name="${db}" 2&>1 /dev/null
    dbCheck="1"
    fi

    if [[ -z $checkdb_user ]]
    then
    uapi --user="${valueUser}" Mysql create_user name="${db_user}" password="${db_pass}" 2&>1 /dev/null
    uapi --user="${valueUser}" Mysql set_privileges_on_database user="${db_user}" database="${db}" privileges=ALL PRIVILEGES 2&>1 /dev/null
    dbUserCheck="1"
    else
    whmapi1 set_mysql_password user="${db_user}" password="${db_pass}" cpuser="${valueUser}"
    _checkExecution $?
    uapi --user="${valueUser}" Mysql set_privileges_on_database user="${db_user}" database="${db}" privileges=ALL PRIVILEGES 2&>1 /dev/null
    dbUserCheck="1"
    fi
}
_confValidation(){
if [[ -f ${databaseConfiguration} ]]
then

   if [[ ${valueType} = "2" ]] || [[ ${valueType} = "3" ]]
   then
   db=$(cat ${databaseConfiguration} 2> /dev/null|\
   grep -v "^#production"| grep -A8 "^production" | grep "database" | cut -f2 -d":" | tr -d ' ')
   db_user=$(cat ${databaseConfiguration} 2> /dev/null|\
   grep -v "^#production"| grep -A8 "^production" | grep "username" | cut -f2 -d":" | tr -d ' ')
   db_pass=$(cat ${databaseConfiguration} 2> /dev/null|\
   grep -v "^#production"| grep -A8 "^production" | grep "password" | cut -f2 -d":" | tr -d ' ')
   fi
   
   if [[ -n ${db} ]] && [[ -n ${db_user} ]] && [[ -n ${db_pass} ]]
   then
    
        case ${valueType} in
        '2')
            if [[ "$OldRedmineVersion" < "$VERSION" ]]
            then
                _createBackup
                _checkExecution $?
                _newInstall
                _checkExecution $?

                _syncFiles
                _checkExecution $?

                _bundleInstall
                _checkExecution $?

                _bundleExec
                _checkExecution $?

                _createPassengerApp
                    
            elif [[ "$OldRedmineVersion" == "$VERSION" ]]
            then
                echo -e "${VERMELHO}[ERROR] :: RedMine is already in the latest version!${RESETCOR}"
            else
                echo -e "${VERMELHO}[ERROR] :: Upgrade of $oldRedmineVersion to $VERSION is not aplicable, contact an L2 or L3!${RESETCOR}"
            fi
        ;;
        '3')
        #Only bundle supported version 4.0.4
        if [[  "$OldRedmineVersion" == "$VERSION" ]]
        then
            _bundleInstall
            _checkExecution $?
            _bundleExec
            _checkExecution $?
        else
            echo -e "${VERMELHO}[ERROR] :: Bundle Function only Works on RedMine 4.0.4, Upgrade First!${RESETCOR}"
        fi
        ;;
        esac
   fi

else
echo -e "${VERMELHO}[ERROR] :: Check database.yml configuration!${RESETCOR}"
fi
    }

_newInstall(){    
    case ${valueType} in
    '1')
        if [[ ! -d "${WorkDir}" ]]
        then
        echo -e "${VERDE}[INFO] :: Executing New Install [Executing]${RESETCOR}"
        sleep 1
        su ${valueUser} -c "mkdir -p ${WorkDir:-VAZIO} 1> /dev/null 2> $logExec"
        _checkExecution $?
        su ${valueUser} -c "cd ${WorkDir} && wget $PACKAGE 1> /dev/null 2> $logExec"
        su ${valueUser} -c "cd ${WorkDir} && tar -xzf redmine-${VERSION}.tar.gz 1> /dev/null 2> $logExec"
        su ${valueUser} -c "cd ${WorkDir} && mv redmine{-${VERSION},_${data}}"
        su ${valueUser} -c "cd ${RedmineDir} && mv config/database.yml{.example,}"
        _createDB
        _checkExecution $?
        cd ${RedmineDir} && sed -i "s@`cat config/database.yml|grep -v ^#production|grep -A8 ^production|grep database|cut -f2 -d":"| tr -d ' '`@${db}@g" config/database.yml
        cd ${RedmineDir} && sed -i "s@`cat config/database.yml|grep -v ^#production|grep -A8 ^production|grep username|cut -f2 -d":"|tr -d ' '`@${db_user}@g" config/database.yml
        cd ${RedmineDir} && sed -i "s@`cat config/database.yml|grep -v ^#production|grep -A8 ^production|grep password|cut -f2 -d":"| tr -d ' '`@\"${db_pass}\"@g" config/database.yml
        _bundleInstall 
        _checkExecution $?
        _bundleExec
        _checkExecution $?
        _createPassengerApp
        else
        echo -e "${AMARELO}[WARN] :: Directory already exists!${RESETCOR}"
        echo -e "${VERDE}[INFO] :: Invalid instalation type, PATH is busy, invoke upgrade option!${RESETCOR}"
        exit 0
        fi
    ;;
    '2')
        su ${valueUser} -c "cd ${WorkDir} && wget $PACKAGE 1> /dev/null 2> $logExec"
        su ${valueUser} -c "cd ${WorkDir} && tar -xzf redmine-${VERSION}.tar.gz 1> /dev/null 2> $logExec"
        su ${valueUser} -c "cd ${WorkDir} && mv redmine{-${VERSION},_${data}}"
    ;;
    esac
}

_checkInstall(){
    case ${valueType} in
        '2')
            if [[ -d "${valuePath}" ]]
            then     
            _confValidation
            else
            echo -e "${VERMELHO}[ERROR] :: Invalid PATH, check upgrade PATH!${RESETCOR}"
            fi

        ;;
        
        '3')
            if [[ -d "${valuePath}" ]] 
            then
            _confValidation
            else
            echo -e "${VERMELHO}[ERROR] :: Invalid PATH, check bundle PATH!${RESETCOR}"
            fi
        ;;

        '*')
        echo -e "${VERMELHO}[ERROR] :: Invalid value for Check Install, contact an L2 or L3! [exiting]${RESETCOR}"
        ;;
        esac
}

_main() {
    if [[ -n $valueUser ]] && [[ -n $valuePath ]] && [[ -n $valueType ]] && [[ -n $valueDomain ]]
    then
    _userCheck
    _typeCheck
    _domainCheck
    _defineWorkDir    
    else
    echo -e "${VERMELHO}[ERROR] :: Verify parameters! [INFO] ${RESETCOR}"
    exit 0
    fi

    if [[ "${userCheck}" != 0 ]] && [[ "${typeCheck}" != 0 ]] && [[ "${domainCheck}" != 0 ]]
    then
    > $logExec
    chown $valueUser.$valueUser $logExec
    _checkExecution $?
    
    echo -e "${VERDE}[INFO] :: Checking dependencies [Executing]${RESETCOR}"
    _jailshellCheck
    _checkExecution $? 
        case "${valueType}" in
            
            '1')
            #New
            _newInstall
            echo -e "${VERDE}[INFO] :: Execution time: $(($SECONDS / 3600)) hours $((($SECONDS / 60) % 60)) minutes $(($SECONDS % 60)) seconds. ${RESETCOR}"
            ;;

            '2')
            #--Upgrade
            _checkInstall
            echo -e "${VERDE}[INFO] :: Execution time: $(($SECONDS / 3600)) hours $((($SECONDS / 60) % 60)) minutes $(($SECONDS % 60)) seconds. ${RESETCOR}"
            ;;
            
            '3')
            _checkInstall
            echo -e "${VERDE}[INFO] :: Execution time: $(($SECONDS / 3600)) hours $((($SECONDS / 60) % 60)) minutes $(($SECONDS % 60)) seconds. ${RESETCOR}"
            ;;
            
            *)
                #Error
                echo -e "${VERMELHO}[ERROR] :: Invalid Option!${RESETCOR}"
                _usage
                exit 1
            ;;
            esac
    
    else 
    echo -e "${VERMELHO} Check Parameters or contact a L2/L3 for support! ${RESETCOR}"
    exit 1
    fi        
}

if [[ "$#" == "4" ]]
then
_main
else
echo -e "${VERMELHO} Check Parameters or contact a L2/L3 for support! ${RESETCOR}"
_usage
fi
