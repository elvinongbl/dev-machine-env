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
The installer (install.sh) performs the follow:-
a) Software packages commonly used

b) Environment settings:
   - $HOME/.vimrc
   - $HOME/.dircolors
   - $HOME/.bash_aliases: convenient alias and also personalized PS1
   - $HOME/.gitconfig : main git configuration
   - $HOME/own-repos/.gitconfig : github.com git configuration

c) Install some extra convenient helper bash scripts under $HOME/common/bin
   and add the $HOME/common/bin to environment variable PATH.

3) To git clones git repos that have been of interest,
```
$ ./init-repos.sh
```
Note:
 - $HOME/own-repos: contains personal repo and uses $HOME/own-repos/.gitconfig
 - $HOME/public-repos: contains public repos and uses $HOME/.gitconfig
 - $HOME/public-repos contains further sub-group of repos:
   * oss-bpf
   * oss-learning
   * oss-linux
   * oss-netconf
   * oss-yocto

4) To setup for BPF development environment
```
$ ./setup-bpf-env.sh
```
