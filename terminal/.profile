eval "$(rbenv init -)"
if [ "$PATHS" != "true" ]; then
    export PATHS="true"
#Manipulate and export PATH over here
fi
if [ "x" == "x`ps -x -u ${USER} | egrep [s]sh-agent`" ] ; then
	ssh-agent | sed -e "/^echo/d" > ${HOME}/bin/agent-env
fi
source ${HOME}/bin/agent-env
