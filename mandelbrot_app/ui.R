library(shiny)


shinyUI(fluidPage(
    sidebarLayout(
        sidebarPanel(
            numericInput('max_level', 
                         label = 'Max Level (start here)', 
                         value = 0,
                         min = 0,
                         max = 1000,
                         step = 1),
            numericInput('trials', 
                         label = 'Trials (not used for plotting)', 
                         value = 1,
                         min = 1,
                         max = 1000,
                         step = 1),
            numericInput('sample_size', 
                         label = 'Sample Size', 
                         value = 1e+5,
                         min = 1e+5,
                         max = 1e+7,
                         step = 1e+5),
            actionButton('action_plot', label = "Plot", style='color:blue'),
            hr(),
            radioButtons('foreach_backend', 
                         label = "foreach Backend",
                         choices = list("Sequential" = 'registerDoSEQ', 
                                        "Parallel" = 'registerDoParallel'), 
                         selected = 'registerDoSEQ',
                         inline = TRUE),
            fluidRow(
                column(width = 3, strong("Instance")),
                column(width = 6, strong("Private IP")),
                column(width = 3, strong("Cores"))
            ),            
            lapply(1:3, function(i) {
                fluidRow(
                    column(
                        width = 3, 
                        h5( paste('Instance', i) )
                    ),
                    column(
                        width = 6, 
                        textInput(paste0("private_ip", i), 
                                  label = NULL,
                                  value = ifelse(i==1, 'localhost', 'x.x.x.x'))
                    ),
                    column(
                        width = 3, 
                        numericInput(paste0("cores", i), 
                                     label = NULL, 
                                     value = 0,
                                     min = 0,
                                     step = 1)
                    )
                )
            }),
            pre(paste0('Enter "localhost" above for the master server IP.\n',
                       'Enter "0" cores not to use a certain instance.')),
            textInput('master_ip', 
                      label = 'Master Private IP (do not enter "localhost")',
                      value = 'x.x.x.x'),
            numericInput('port', 
                         label = 'Port', 
                         value = 11011,
                         min = 11000,
                         max = 11999,
                         step = 1),
            textInput('rshcmd', 
                      label = 'Remote Shell Command (created by you for explore_makeCluster.R)',
                      value = 'ssh'),            
            pre(paste0('Windows: "C:/###/plink.exe" -i "c:/###/###.ppk" \n',
                       'AWS EC2 / ubuntu: ssh')),
            textInput('user', 
                      label = 'User',
                      value = 'ubuntu'),
            checkboxInput('homogeneous', 
                          label = strong("Homogeneous (TRUE for AWS EC2)"), 
                          value = TRUE),
            actionButton('action_area', label = "Calculate area (double check the inputs)", style='color:red'),
            width = 4
        ),
        
        mainPanel( 
            tabsetPanel(
                tabPanel('Plot Area', 
                         plotOutput('plot_area',  height = "600px")),
                tabPanel('Raw Calculations', 
                         tableOutput('raw')),
                tabPanel('Summary', 
                         tableOutput('summary')),
                tabPanel('Plot Convergence', 
                         plotOutput('plot_convergence',  height = "600px")),
                type = "tabs"
            )
        )
    ), 
    title="Multicore Multinode R / Shiny"
))
