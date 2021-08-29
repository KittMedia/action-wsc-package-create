#!/bin/bash
# Build a valid WCF package

ENTRYPOINT=$(realpath $0)
GIVEN_PACKAGE_NAME="${1%/}"
PACKAGE_TYPE=${2%/}

if [ ! -z "${PACKAGE_TYPE}" ]; then
  DO_COMPRESS=false
else
  DO_COMPRESS=true
fi

if [ -z "$GIVEN_PACKAGE_NAME" ]; then
  PACKAGE_NAME=${GITHUB_REPOSITORY#*/}
else
  PACKAGE_NAME=${GIVEN_PACKAGE_NAME}
fi

echo "GitHub Repository: ${GITHUB_REPOSITORY}"
echo "Package Name: ${PACKAGE_NAME}"
echo "Package Type: ${PACKAGE_TYPE}"

[ -z $PACKAGE_NAME ] && exit 1
echo "enter ${GITHUB_WORKSPACE}"
cd $GITHUB_WORKSPACE


if [ "${PACKAGE_TYPE}" = "requirement" ]; then
	echo "enter requirements/${PACKAGE_NAME}/"
  cd requirements/${PACKAGE_NAME}/
  ls -l
elif [ "${PACKAGE_TYPE}" = "optional" ]; then
	echo "enter optionals/${PACKAGE_NAME}/"
  cd optionals/${PACKAGE_NAME}/
  ls -l
fi

ls -l
test -e composer.json && echo -e "\nComposer installation\n-----------" && composer install
test -e acptemplate && echo -e "\nBuilding acptemplate.tar\n-------------------------" && cd acptemplate && tar cvf ../acptemplate.tar --exclude=.git* * && cd ..
test -e acptemplates && echo -e "\nBuilding acptemplates.tar\n-------------------------" && cd acptemplates && tar cvf ../acptemplates.tar --exclude=.git* * && cd ..
test -e file && echo -e "\nBuilding file.tar\n------------------" && cd file && tar cvf ../file.tar --exclude=.git* * && cd ..
test -e files && echo -e "\nBuilding files.tar\n------------------" && cd files && tar cvf ../files.tar --exclude=.git* * && cd ..
test -e files_preinstall && echo -e "\nBuilding files_preinstall.tar\n-----------------------------" && cd files_preinstall && tar cvf ../files_preinstall.tar --exclude=.git* * && cd ..
test -e files_wcf && echo -e "\nBuilding files_wcf.tar\n----------------------" && cd files_wcf && tar cvf ../files_wcf.tar --exclude=.git* * && cd ..
test -e template && echo -e "\nBuilding template.tar\n----------------------" && cd template && tar cvf ../template.tar --exclude=.git* * && cd ..
test -e templates && echo -e "\nBuilding templates.tar\n----------------------" && cd templates && tar cvf ../templates.tar --exclude=.git* * && cd ..
test -e templates_wcf && echo -e "\nBuilding templates_wcf.tar\n-------------------" && cd templates_wcf && tar cvf ../templates_wcf.tar --exclude=.git* * && cd ..

if [ -e "requirements" ]; then
  echo -e "\nBuilding requirements\n---------------------"
  cd requirements/
  ls -l
  
  for PACKAGE in *; do
  	echo "Building required package ${PACKAGE}"
    $ENTRYPOINT $PACKAGE "requirement"
  done
  
  rm -r */
  cd ..
fi

if [ -e "optionals" ]; then
  echo -e "\nBuilding optionals\n------------------"
  cd optionals/
  ls -l
  
  for PACKAGE in *; do
  	echo "Building optional package ${PACKAGE}"
    $ENTRYPOINT $PACKAGE "optional"
  done
  
  rm -r */
  cd ..
fi

if [ "${DO_COMPRESS}" = true ]; then
  echo -e "\nBuilding $PACKAGE_NAME.tar.gz"
  echo -n "----------------"
  
  for i in `seq 1 ${#PACKAGE_NAME}`; do
      echo -n "-"
  done
  
  echo -en "\n"
  tar cvfz ${PACKAGE_NAME}.tar.gz --exclude=file --exclude=files --exclude=files_preinstall --exclude=files_wcf --exclude=acptemplate --exclude=acptemplates --exclude=template --exclude=templates --exclude=wcf-buildscripts --exclude=README* --exclude=CHANGELOG --exclude=LICENSE --exclude=.git* --exclude=composer* *
else
  echo -e "\nBuilding $PACKAGE_NAME.tar"
  echo -n "-------------"
  
  for i in `seq 1 ${#PACKAGE_NAME}`; do
      echo -n "-"
  done
  
  echo -en "\n"
  tar cvf ${PACKAGE_NAME}.tar --exclude=file --exclude=files --exclude=files_preinstall --exclude=files_wcf --exclude=acptemplate --exclude=acptemplates --exclude=template --exclude=templates --exclude=wcf-buildscripts --exclude=README* --exclude=CHANGELOG --exclude=LICENSE --exclude=.git* --exclude=composer* *
fi

if [ "${PACKAGE_TYPE}" = "requirement" ]; then
  if [ "${DO_COMPRESS}" = true ]; then
    mv ${PACKAGE_NAME}.tar.gz ${GITHUB_WORKSPACE}/requirements/
  else
    mv ${PACKAGE_NAME}.tar ${GITHUB_WORKSPACE}/requirements/
  fi
elif [ "${PACKAGE_TYPE}" = "optional" ]; then
  if [ "${DO_COMPRESS}" = true ]; then
    mv ${PACKAGE_NAME}.tar.gz ${GITHUB_WORKSPACE}/optionals/
  else
    mv ${PACKAGE_NAME}.tar ${GITHUB_WORKSPACE}/optionals/
  fi
fi

exit 0
