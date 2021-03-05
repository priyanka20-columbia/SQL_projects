
server <- function(input, output, session) {
  
  # background image----
  output$image <- renderUI(
    if (input$arts != '')
    {
      imageName = sub(" ", "", tolower(input$arts))
      setBackgroundImage(src = paste(imageName, ".png", sep =""))
    }
  )
  
  # small image----
  output$artImg <- renderUI(
    if (input$arts != '') {
      imageName = sub(" ", "", tolower(input$arts))
      div(img(src = paste(imageName, ".png", sep =""), width = "100%"))
     
    }
  )
  
  # plays title----
  output$PlaysTitle <- renderText(
    if (input$arts != '') {
        title = paste0("<h4>Plays of ", input$arts, " Songs by Month</h4>",sep = " ")
    }
  )
  
  # songs title----
  output$SongsTitle <- renderText(
    if (input$arts != '') {
      title = paste("<h4>Songs by", input$arts , "</h4>",sep = " ")

    }
  )
  
  # reactive variables----
  a <- reactiveValues(sel = NULL, nS = 0, aR = 0, nP = 0)
  
  # render the summary metrics----
  output$nSongs <- renderText(paste0('<h4>', a$nS, '</h4>'))
  output$avgRat <- renderText(paste0('<h4>', a$aR, '</h4>'))
  output$nPlays <- renderText(paste0('<h4>', a$nP, '</h4>'))
  
  # chart of plays by month----
  output$playChrt <- renderPlot(
    {
      if (input$arts != '') {
        d <- dbGetQuery(
          conn = con, 
          statement <- paste0('select Count(play_id)::numeric "Plays", Extract(month from dop)::numeric "Month" ',
                             'from plays ', 
                            'where artist ilike \'%', input$arts, '%\' ',
                             'group by Extract(month from dop) ;')
        ) 
          ggplot(d, aes(x = Month, y = Plays )) +
            theme_minimal() +
            scale_x_discrete(limits=c( 3, 6, 9, 12)) +
            theme(
              axis.title.x = element_text(size=16),
              axis.title.y = element_text(size=16),
              axis.text.x = element_text(size = 14),
              axis.text.y = element_text(size = 14)
            )  +
            geom_point(size = 2.5, color="red") +
            geom_smooth()
          # 
          # p2 <- ggplot(data, aes(x=my_x, y=my_y)) +
          #   geom_point() +
          #   geom_smooth(method=lm , color="red", se=FALSE) +
          #   theme_ipsum()
        
      }
    }
  )
  
  # populate the reactive variable a when an artist is selected----
  observeEvent(
    eventExpr = input$arts,
    {
      session = session
      inputId = 'arts'
      # _data for the songs table----
      a$sel <- dbGetQuery(
        conn = con, 
        statement = paste0('Select dor "Date of Release", song_name "Song Name", ', 
                    'case rating ', 
                    'when 1 then \'*\' ',
                    'when 2 then \'* *\' ',
                    'when 3 then \'* * *\' ',
                    'when 4 then \'* * * *\' ',
                    'when 5 then \'* * * * *\' ',
                    'end as "Rating" ',
                    'from songs ',
                    'where artist ilike \'%', input$arts, '%\'; ')
      )
      # _data for number of songs metric----
      if (input$arts == '') {
        a$nS = 0
      }else{
      a$nS <- dbGetQuery(
        conn = con, 
        statement = paste0('Select count(*)::numeric ',
                           'from songs ',
                           'where artist ilike \'%', input$arts, '%\'; ')
      )
      }
      # _data for average rating metric----
      if (input$arts == '') {
        a$aR = 'NA'
      }else{
      a$aR <- dbGetQuery(
        conn = con, 
        statement = paste0('Select ROUND(avg(rating),2) ',
                           'from songs ',
                           'where artist ilike \'%', input$arts, '%\'; ')
      )
      }
      # _data for number of plays metric----
      if (input$arts == '') {
        a$nP = 0
      }else{
      a$nP <- dbGetQuery(
        conn = con, 
        statement = paste0('Select count(*)::numeric ',
                           'from plays ',
                           'where artist ilike \'%', input$arts, '%\'; ')
      )
      }
    }
  )
  
  # table of songs by selected artist----
  output$songsA <- renderDataTable(
    if (input$arts != '') {
      data = a$sel
    }, options = list(
      pageLength = 10
      )
  )
  
}

