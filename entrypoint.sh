#!/bin/bash
# Build a valid WCF package

PACKAGE_NAME=${GITHUB_REPOSITORY#*/}

[ -z $PACKAGE_NAME ] && exit 1
cd $GITHUB_WORKSPACE
ls -l
test -e composer.json && echo -e "\nComposer installation\n-----------" && composer install
test -e acptemplate && echo -e "\nBuilding acptemplate.tar\n-------------------------" && cd acptemplate && tar cvf ../acptemplate.tar --exclude=.git* * && cd ..
test -e acptemplates && echo -e "\nBuilding acptemplates.tar\n-------------------------" && cd acptemplates && tar cvf ../acptemplates.tar --exclude=.git* * && cd ..
test -e file && echo -e "\nBuilding file.tar\n------------------" && cd file && tar cvf ../file.tar --exclude=.git* * && cd ..
test -e files && echo -e "\nBuilding files.tar\n------------------" && cd files && tar cvf ../files.tar --exclude=.git* * && cd ..
test -e files_preinstall && echo -e "\nBuilding files_preinstall.tar\n-----------------------------" && cd files_preinstall && tar cvf ../files_preinstall.tar --exclude=.git* * && cd ..
test -e files_wcf && echo -e "\nBuilding files_wcf.tar\n---------------------" && cd files_wcf && tar cvf ../files_wcf.tar --exclude=.git* * && cd ..
test -e template && echo -e "\nBuilding template.tar\n----------------------" && cd template && tar cvf ../template.tar --exclude=.git* * && cd ..
test -e templates && echo -e "\nBuilding templates.tar\n----------------------" && cd templates && tar cvf ../templates.tar --exclude=.git* * && cd ..

echo -e "\nBuilding $PACKAGE_NAME.tar.gz"
echo -n "----------------"
for i in `seq 1 ${#PACKAGE_NAME}`;
do
		echo -n "-"
done
echo -en "\n"
tar cvfz ${PACKAGE_NAME}.tar.gz --exclude=file --exclude=files --exclude=files_preinstall --exclude=files_wcf --exclude=acptemplate --exclude=acptemplates --exclude=template --exclude=templates --exclude=wcf-buildscripts --exclude=README* --exclude=CHANGELOG --exclude=LICENSE --exclude=.git* --exclude=composer* *

# Prepare SSH
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	chmod 700 ~/.ssh
fi

ssh-keyscan -H ${REMOTE_HOST} > ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts
cat ~/.ssh/known_hosts

cat > ~/.ssh/id_deploy_key <<EOL
$SSH_PRIVATE_KEY
EOL

chmod 600 ~/.ssh/id_deploy_key

# Create directory
echo "Create directory /${REMOTE_PATH_BASE#*/}/${GITHUB_REPOSITORY#*/}/${GITHUB_SHA}"
ssh -v ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p /${REMOTE_PATH_BASE#*/}/${GITHUB_REPOSITORY#*/}/${GITHUB_SHA}"

# Store artifact package via SSH
echo "Upload ${PACKAGE_NAME}.tar.gz to /${REMOTE_PATH_BASE#*/}/${GITHUB_REPOSITORY#*/}/${GITHUB_SHA}"
scp -v ${PACKAGE_NAME}.tar.gz ${REMOTE_USER}@${REMOTE_HOST}:/${REMOTE_PATH_BASE#*/}/${GITHUB_REPOSITORY#*/}/${GITHUB_SHA}

exit 0
