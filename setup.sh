#!/bin/bash
SCRIPT_PATH=`pwd`;

ALIAS='function simple-watcher(){
	ruby '$SCRIPT_PATH'/simple-watcher.rb "$@"
}
export -f simple-watcher
export PATH=$PATH:'$SCRIPT_PATH''

command="echo '$ALIAS' >> ~/.bashrc && . ~/.bashrc"
bashrc_content=`cat ~/.bashrc`
if [[ "$bashrc_content" != *$ALIAS* ]]; then
  eval "$command"
  echo "added: ${ALIAS} to ~/.bashrc"
fi
echo "done"
