# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases