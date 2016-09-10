node("linux && docker") {
    docker.image('rocker/hadleyverse').inside {
	checkout scm
        stage 'Clean'
        sh 'rm -rf packrat/lib* *.Rcheck bagOfWords-*.tar.gz'
        
        stage 'Update Dependencies'
        writeFile file: '.Rprofile', text: '''options(repos = c(CRAN = "https://cran.rstudio.com"))
#### -- Packrat Autoloader (version 0.4.7-9) -- ####
source("packrat/init.R")
#### -- End Packrat Autoloader -- ####
'''
        env.R_PACKRAT_CACHE_DIR = "${pwd()}/.packrat_cache"
        sh 'mkdir -p $R_PACKRAT_CACHE_DIR'

        sh 'R -f packrat/init.R --args --bootstrap-packrat'

        stage 'Check'
        sh 'R -e "devtools::check()"'

        stage 'Get Results'
        archive 'bagOfWords-*.tar.gz'
    }
}
