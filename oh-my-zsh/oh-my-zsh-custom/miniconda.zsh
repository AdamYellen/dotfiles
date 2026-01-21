if [ -x /opt/homebrew/bin/conda ]
then
   eval "$(/opt/homebrew/bin/conda "shell.$(basename "${SHELL}")" hook)"
fi
