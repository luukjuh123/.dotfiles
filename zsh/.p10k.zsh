# Powerlevel10k config — Pure style with always-visible host context.
# Tracked in ~/.dotfiles. Regenerate with `p10k configure` only if you want
# to start from scratch; otherwise edit this file directly.
#
# Differences from the stock Pure config:
#   - `context` (user@host) is always shown on the right, so you can tell
#     which machine you're on. Honors $MACHINE_LABEL if set.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Prompt colors.
  local grey='250'
  local red='9'
  local yellow='11'
  local blue='12'
  local magenta='13'
  local cyan='14'
  local white='15'
  local green='10'

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                       # current directory
    vcs                       # git status
    prompt_char               # prompt symbol
  )

  # Right prompt segments — context (user@host) is now always visible.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time    # previous command duration
    virtualenv                # python virtual environment
    context                   # user@host  (always visible — see below)
    time                      # current time
  )

  # Basic style.
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # Prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$magenta
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

  # virtualenv
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$grey
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # Current directory — cyan.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$cyan

  # -------------------------------------------------------------------------
  # Context (user@host) — ALWAYS VISIBLE.
  # Uses $MACHINE_LABEL if set, otherwise the short hostname.
  # Root is highlighted; SSH gets the same treatment as local so a VM looks
  # the same whether you're SSHed in or sitting at its console.
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=$green
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=$yellow
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$red
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND=$red

  # %n = user, ${MACHINE_LABEL:-%m} = label override or short hostname.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@${MACHINE_LABEL:-%m}'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@${MACHINE_LABEL:-%m}'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_TEMPLATE='%n@${MACHINE_LABEL:-%m}'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_TEMPLATE='%n@${MACHINE_LABEL:-%m}'

  # Force the segment to render in every state (default Pure config hides it
  # for non-root non-SSH).
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='${P9K_CONTENT}'
  typeset -g POWERLEVEL9K_CONTEXT_SUDO_CONTENT_EXPANSION='${P9K_CONTENT}'

  # Command execution time.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$yellow

  # Git.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$grey
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0
  typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND=$cyan
  typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED}_ICON=
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='*'
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=':⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=':⇡'
  typeset -g POWERLEVEL9K_VCS_{COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=1
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${${${P9K_CONTENT/⇣* :⇡/⇣⇡}// }//:/ }'

  # Time.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$grey
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # Transient prompt.
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # Instant prompt.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
