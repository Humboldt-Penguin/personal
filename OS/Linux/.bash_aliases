alias 'launch509'="cd /home/lain/sync/02_Rutgers/PHY509 && conda activate && mamba activate 5091 && jupyter lab --no-browser"

alias 'gotomars'="cd /home/lain/sync/01_Research/Mars_Magnetics"

alias 'launchmars'="gotomars && conda activate && mamba activate mars2 && jupyter lab --no-browser"

alias 'exportenv'="mamba env export --from-history > environment_$(date +"%y%m%d_%H%M").yml"
