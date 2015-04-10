# Add composer to the  path
export PATH=$HOME/.composer/vendor/bin:$PATH
# Add drush to the path
export PATH=$HOME/drush:$PATH

# aliases
alias sql="mysql -uroot"
alias sites="cd ~/Sites"
alias u2d="php ~/Documents/scripts/utcToReadable.php"
alias d2u="php ~/Documents/scripts/toTimestamp.php"
alias purp.local="drush @purplepatchfitness.local"
alias purp.dev="drush @purplepatchfitness.dev"
alias purp.stage="drush @purplepatchfitness.test"
alias purp.prod="drush @purplepatchfitness.prod"
alias dcs="phpcs --standard=/users/jesse/.composer/vendor/drupal/coder/coder_sniffer/Drupal"
alias prune="~/Documents/scripts/directory_unchanged.sh"
alias doc="php ~/phpDocumentor.phar"
alias apigen="php /Users/jesse/.composer/vendor/bin/apigen.php"
alias unloadaudio="sudo kextunload /System/Library/Extensions/AppleHDA.kext"
alias loadaudio="sudo kextload /System/Library/Extensions/AppleHDA.kext"
alias jmeter="/Users/jesse/Applications/apache-jmeter-2.13/bin/jmeter"
alias drush7="/Users/jesse/.composer/vendor/bin/drush"
  
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

export PATH="$PATH:/Applications/DevDesktop/drush"
export PATH="$PATH:/Users/jesse/tools/Hound/"
