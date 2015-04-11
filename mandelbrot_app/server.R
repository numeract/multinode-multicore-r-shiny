library(shiny)
library(parallel)
library(doParallel)
library(foreach)
library(ggplot2)
library(RColorBrewer)
library(dplyr)


plot_area <- function(max_level = 1, sample_size = 1e+6) {
    if (max_level<=0) return(NULL)
    max_level <- min(max_level, 25)
    
    r <- 2
    x <- runif(sample_size, min = -r, max = +r)
    y <- runif(sample_size, min = -r, max = +r)
    c <- complex(real = x, imaginary = y)
    level <- rep(0, sample_size)
    
    # Mandelbrot set iterations; max_level == 1 simple circle
    z <- 0
    for (j in 1:max_level) {
        z <- z ** 2 + c
        level[Mod(z) <= r] <- j
    }
    
    df <- data.frame(x=x, y=y, level=level)[level>0, ]
    df$mod_level <- as.factor(df$level)
    if (max_level==1) {
        level_colors <- 'black'
    } else {
        level_colors <- rep(brewer.pal(3, 'PuBu'), max_level)
        level_colors <- c(level_colors[1:(max_level-1)], 'black')
    }
    
    ggplot(df, aes(x, y, color = mod_level)) + 
        geom_point(size=0.5) + 
        coord_fixed() + xlim(-2, 2) + ylim(-2, 2) + 
        scale_colour_manual(values = level_colors)
} 


calc_area <- function(max_level = 1, sample_size = 1e+6) {
    if (max_level<=0) return(NULL)
    
    r <- 2
    x <- runif(sample_size, min = -r, max = +r)
    y <- runif(sample_size, min = -r, max = +r)
    c <- complex(real = x, imaginary = y)
    
    # Mandelbrot set iterations; max_level == 1 simple circle
    z <- 0
    for (j in 1:max_level) {
        z <- z ** 2 + c
    }
    
    # points not diverging
    count_inside <- sum( Mod(z) <= r )
    fractional_area <- count_inside / sample_size
    # area square: 2r x 2r
    return( (2*r)^2 * fractional_area ) 
} 


shinyServer(function(input, output, session) {
    
    cl <- NULL
    backend <- reactive({
        # react to buttons
        input$action_area
        
        # sequential mode? easy
        if (input$foreach_backend=='registerDoSEQ'){
            cl <<- NULL
            registerDoSEQ()      # returns 1
            return(getDoSeqWorkers())
        }
        
        # parallel mode
        spec <- c(rep(input$private_ip1, input$cores1), 
                  rep(input$private_ip2, input$cores2), 
                  rep(input$private_ip3, input$cores3))
        
        # last attepts to catch an error
        if (length(spec)==0) {
            cl <<- NULL
            return(0)
        }
        if (input$rshcmd == '') {
            cl <<- NULL
            return(0)
        }
        
        # WARNINNG: if wrong values are used, makeCluster will hang
        cl <<- makeCluster(
            spec = spec,
            master = input$master_ip,
            port = input$port,
            rshcmd = input$rshcmd,
            user = input$user,
            homogeneous = input$homogeneous,
        )     
        
        # register parallel backend
        registerDoParallel(cl)
        return(getDoParWorkers())
    })
    
    
    output$plot_area <- renderPlot({
        # react to $action_plot
        input$action_plot
        
        gg <- plot_area(isolate(input$max_level), 
                        isolate(input$sample_size))
        print(gg)
    })
    
    
    calculations <- eventReactive(input$action_area, {
        if (input$max_level<=0) return(NULL)
        
        # check backend (it may hang!)
        if(backend()==0) return(NULL)
        
        # local variables
        max_level_local <- input$max_level 
        trials_local <- input$trials
        sample_size_local <- input$sample_size
        
        areas <- tryCatch(
            foreach(l = 1:max_level_local, 
                    .combine = rbind,
                    #.errorhandling = c('pass'),
                    #.packages = NULL, 
                    .export = 'calc_area') %:% 
                
                foreach(t = 1:trials_local, 
                        .combine = rbind, 
                        #.errorhandling = c('pass'),
                        #.packages = NULL, 
                        .export = NULL) %dopar% {
                            
                            # main calculations
                            area <- calc_area(l, sample_size_local)
                            
                            # return a nice data frame for row binding
                            data.frame(level=l, trial=t, area=area)
                        },
            
            # we want to be sure that we close the connections
            finally = {
                if (!is.null(cl)) {
                    stopCluster(cl)
                    cl <<- NULL
                }
            }
        )
        return(areas)
    })
    
    
    output$raw <- renderTable({
        calculations()
    }, digits = 10)
    
    
    output$summary <- renderTable({
        df_calc <- calculations()
        df_summary <- summarise(group_by(df_calc, level), mean(area))
        df_summary$pi <- df_summary$'mean(area)' / 2 ^ 2
        return(df_summary)
    }, digits = 10)
    
    
    output$plot_convergence <- renderPlot({
        df_calc <- calculations()
        df_summary <- summarise(group_by(df_calc, level), mean(area))
        colnames(df_summary) <- c('level', 'mean_area')
        
        gg <- ggplot(df_summary, aes(x=level, y=mean_area)) + 
            geom_line() + scale_x_log10() 
        print(gg)
    })
})

