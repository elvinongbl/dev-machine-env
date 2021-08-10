# To automate development machine setup

1) Download and unzip the release package
   Note: Check https://github.com/elvinongbl/dev-machine-env/releases
         for desired release package and copy the zipped package URL.
   For example:-
     https://github.com/elvinongbl/dev-machine-env/archive/refs/tags/v0.5.0.zip

```
$ curl -fsSL -o dev-machine-env.zip -L <URL of zipped package>
$ unzip dev-machine-env.zip
```

2) Execute the installer script and enter your user's password when prompted
```
$ ./install.sh
```

# Additional informations:
The installer (install.sh) performs the follow:-
1) Software packages commonly used

2) Environment settings:
   - $HOME/.vimrc
   - $HOME/.dircolors
   - $HOME/.bash_aliases: convenient alias and also personalized PS1
   - $HOME/.gitconfig : main git configuration
   - $HOME/own-repos/.gitconfig : github.com git configuration

3) Install some extra convenient helper bash scripts under $HOME/common/bin
   and add the $HOME/common/bin to environment variable PATH.
