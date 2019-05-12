library(shiny)

preferred_tags = c("administrative divisions",
                   "common operational dataset - cod",
                   "populated places",
                   "roads",
                   "transportation",
                   "airports",
                   "population statistics",
                   "demographics",
                   "sex and age disaggregated data - sadd",
                   "poverty",
                   "health facilities",
                   "education facilities",
                   "affected schools",
                   "integrated phase classification - ipc",
                   "food security",
                   "global acute malnutrition - gam",
                   "internally displaced persons - idp",
                   "refugees",
                   "persons of concern",
                   "returnees",
                   "affected persons locations",
                   "who is doing what where - 3w",
                   "affected area",
                   "damaged buildings",
                   "humanitarian access",
                   "obstacles",
                   "transportation status",
                   "casualties",
                   "fatalities",
                   "missing persons",
                   "severe acute malnutrition - sam")

# User Interface ----------------------------------------------------------

ui <- fluidPage(
  
  titlePanel(title='HDX Data Quality Checker',windowTitle = 'HDX Data Checking'),
  
  sidebarLayout(
  mainPanel(
  # Image is not rendering...not sure how to fix this issue.
  #img(src='www/hdx_logo.png', align = "right"),
  tabsetPanel(type="tabs",
    # Part 1 ------------------------------------------------------------------
    tabPanel("Part 1",
             h4("Part 1: Is the dataset subnational?"),
             radioButtons("subnational",
                          "Is the dataset subnational, FTS, or HNO?",
                          c("None selected"="","yes","no"))),
    # Part 2 ------------------------------------------------------------------
    tabPanel("Part 2",
             h4("Part 2: Is the resource in an acceptable format?"),
             selectInput("tab_geo",
                         "Is the dataset tabular or geographic?",
                         c("Choose one"="",
                           tabular="tabular",
                           geographic="geographic")),
             conditionalPanel(condition="input.tab_geo == 'geographic'",
                              radioButtons("geo_format",
                                           "What format is the file?",
                                           c("None selected" = "",
                                             "zipped shapefile",
                                             "geodatabase",
                                             "geojson",
                                             "geopackage",
                                             "kml",
                                             "kmz",
                                             "raster"))),
             conditionalPanel(condition="input.tab_geo == 'tabular'",
                              radioButtons("fieldNames_dataRows",
                                           "Are field names and data rows easy to determine?",
                                           c("None selected","yes","no")),
                              selectInput("file_format",
                                          "Is the dataset in xls or xlsx format?",
                                          c("Choose one"="",yes="yes",no="no")),
                              conditionalPanel(condition = "input.file_format == 'yes'",
                                               radioButtons("subcat_tab",
                                                            "Are the required data for a single sub-category on the same tab?",
                                                            c("None selected","yes","no"))),
                              selectInput("location_coord",
                                          "Are there location coordinates?",
                                          c("Choose one"="","yes","no")),
                              conditionalPanel("input.location_coord == 'yes'",
                                               checkboxGroupInput("xy_conditions",
                                                                  "The x and y coordinates are",
                                                                  list("in decimal degree form"="decimal_form",
                                                                       "separated into two columns"="two_columns"),
                                                                  selected = c("decimal_form","two_columns"))))),
    # Part 3 ------------------------------------------------------------------
    tabPanel("Part 3",
             h4("Part 3: Is the resource geographically complete or ''as complete as possible''?"),
             selectInput("locations_comparison",
                         "Is there a comprehensive list of locations to compare against?",
                         c("Choose one" = "","yes","no")),
             conditionalPanel("input.locations_comparison == 'yes'",
                              selectInput("necessary_info",
                                          "Does the resource provide the necessary information for all admin units at whatever levels are being covered?",
                                          c("Choose one" = "","yes","no")),
                              conditionalPanel("input.necessary_info == 'no'", 
                                               radioButtons("missing_data_metadata",
                                                            "Which best describes the missing data?",
                                                            c("None selected" ="", 
                                                              "Missing values are defined in the metadata, and map to real data values.",
                                                              "Missing values indicate that data has not yet been collected in these instances." = "data_not_collected"))
               )),
             
             conditionalPanel("input.locations_comparison=='no'",
                              radioButtons("complete_as_possible",
                                           "Does the dataset claim to be complete, or at least ''as complete as possible'' without significant caveats?", 
                                           c("yes","no")))),
    # Part 4 ------------------------------------------------------------------
    tabPanel("Part 4",
             h4("Part 4: Are location references explicit in the resource or joinable to an available location reference that also appears in the data grid?"),
             selectInput("location_reference",
                         "Does the dataset contain references to location?",
                         c("Choose one"="","yes","no")),
             conditionalPanel("input.location_reference == 'yes'",
                              selectInput("location_defined",
                                          "Are locations defined in the dataset (such as latitude and longitude columns)?",
                                          c("Choose one"="","yes","no")),
                              conditionalPanel("input.location_defined=='no'",
                                               radioButtons("location_join",
                                                            "Do p-vodes or some other identifier make it possible to join the dataset to a location reference that is available in data grid (such as COD admin boundary or a facilities list)?",
                                                            c("None selected","yes","no"))))),
    # Part 5 ------------------------------------------------------------------
    tabPanel("Part 5",
             h4("Part 5: If disaggregated by administrative division, does it use the lowest-used level?"),
             selectInput("disaggregated_level",
                         "Is the data disaggregated to the same level as most other data about the country?",
                         c("Choose one"="","yes","no")),
             conditionalPanel("input.disaggregated_level == 'no'",
                              textInput("levels",
                                        "What level are datasets about this country usually disaggregated to?", 
                                        placeholder = "E.g. admin level 1"))),
    
    # Part 6 ------------------------------------------------------------------    
    tabPanel("Part 6", 
             h4("Part 6: How much of the required information specified in the definition does the resource contain?"),
             selectInput('preferred_tags',
                         'The dataset has the following tag(s):',
                         preferred_tags,
                         multiple=TRUE,
                         selectize=TRUE)),
    tabPanel("Part 6 cont.",
             h4("Follow-up questions to Part 6"),
             conditionalPanel("($.inArray('administrative divisions',input.preferred_tags) > -1)||($.inArray('common operational dataset - cod',input.preferred_tags) > -1)",
                               radioButtons("admin_div",
                                            "Has the humanitarian community working in the location endorsed 
                                             this as the preferred set of administrative boundaries as 
                                             the Common Operational Dataset (COD)?",
                                             c("None selected","yes","no"))),
              conditionalPanel("$.inArray('populated places',input.preferred_tags) > -1",
                               radioButtons('populated_places',
                                            "Are the data vector or tabular with coordinates representing 
                                            the location of populated places (cities, towns, villages)?",
                                            c("None selected","yes","no"))),
              conditionalPanel(condition="$.inArray('roads',input.preferred_tags) > -1 || $.inArray('transportation',input.preferred_tags) > -1",
                               selectInput("roads","Are the data geographic, and describing the location of 
                                           roads with some indication of the importance of each road segment 
                                           in the transportation network?",
                                           c("Choose one"="","yes","no"))),
                               conditionalPanel("input.roads=='yes'",
                                                radioButtons("roads_subquestion1",
                                                             "Does the dataset exclude or indicate roads that 
                                                             are not usable by typical four-wheel-drive vehicles 
                                                             (footpaths, etc.)?",
                                                             c("None selected","yes","no"))),
             conditionalPanel("$.inArray('airports',input.preferred_tags) > -1",
                              selectInput("airports_subquestion1",
                                          "Are the data geographic, and representing all operational airports 
                                          including a name or other unique identifier?",
                                          c("Choose one"="","yes","no"))),
                              conditionalPanel("input.airports_subquestion1 == 'yes'",
                                               radioButtons("airports_subquestion2",
                                                            "Are there indications of what types of aircraft can 
                                                            use each airport?",
                                                            c("None selected","yes","no"))),
             conditionalPanel("$.inArray('population statistics',input.preferred_tags) > -1 ||$.inArray('demographics',input.preferred_tags) > -1",
                              radioButtons("pop_stat_subquestion1",
                                           "Do the data describe total population aggregated by administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('sex and age disaggregated data - sadd',input.preferred_tags) > -1 || $.inArray('population statistics',input.preferred_tags) > -1 || $.inArray('demographics',input.preferred_tags) > -1",
                              radioButtons("sadd_subquestion1",
                                           "Do the data describe total population disaggregated by age and sex categories, 
                                           and aggregated by administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('poverty',input.preferred_tags) > -1",
                              radioButtons("poverty_subquestion1",
                                           "Do the data describe the population living under a defined poverty threshold, 
                                           aggregated by administrative division and represented as a percentage of total 
                                           population or as an absolute number?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('health facilities',input.preferred_tags) > -1",
                              radioButtons("healthfacilities_subquestion1",
                                           "Are the data vector or tabular with coordinates representing health facilities 
                                            with some indication of the type of facility (clinic, hospital, etc.)?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('education facilities',input.preferred_tags) > -1",
                              radioButtons("educationfacilities_subquestion1",
                                           "Are the data vector or tabular with coordinates representing education 
                                            facilities with some indication of the type of facility (school, university, etc.)?",
                                           c("None selected","yes","no"))),
             conditionalPanel(condition="$.inArray('affected_schools',input.preferred_tags) > -1",
                              radioButtons("affected_schools_subquestion1",
                                           "Are the data vector or tabular with coordinates representing education facilities 
                                            that have been affected by a crisis, with some indication of the nature of the 
                                            effect and the operational status of each facility?",
                                           c("None selected","yes","no"))),
             conditionalPanel(condition="$.inArray('integrated phase classification - ipc',input.preferred_tags) > -1 || $.inArray('food security',input.preferred_tags) > -1",
                              radioButtons("food_security_subquestion1",
                                           "Are the data in vector form representing the IPC phase classification or 
                                            in tabular form representing population or percentage of the population 
                                            by IPC phase and administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('global acute malnutrition - gam',input.preferred_tags) > -1",
                              radioButtons('gam_subquestion1',
                                           "Are the data in tabular form specifying the global acute malnutrition (GAM) 
                                            rate by administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('severe acute malnutrition - sam',input.preferred_tags) > -1",
                              radioButtons("sam_subquestion1",
                                           "Are the data in tabular form specifying the sever acute malnutrition (SAM) 
                                           rate by administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('internally displaced persons - idp',input.preferred_tags) > -1",
                              radioButtons("idp_subquestion1",
                                           "Are the data in tabular form, and do they describe the number of people by location?
                                           Locations can be administrative divisions or other locations (such as camps) if an additional
                                           dataset defining those locations is also available.",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('refugees',input.preferred_tags) > -1 || $.inArray('persons of concern',input.preferred_tags) > -1 ",
                              radioButtons("refugees_subquestion1",
                                           "Are the data in tabular form of the number of refugees and persons of concern either in the country
                                           or originating from the country disagreggated by their current location? Locations can be administrative divisions
                                           or other locations (such as camps) if an additional dataset defining those locations is also available or if the 
                                           locations' coordinates are defined in the tabular data.",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('returnees',input.preferred_tags) > -1",
                              radioButtons("returnees_subquestion1",
                                           "Are the data in tabular form of the number of displaced people who have returned?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('who is doing what where - 3w',input.preferred_tags) > -1",
                              radioButtons("3w_subquestion1",
                                           "Are the data a list of organizations working on humanitarian issues, 
                                            by humanitarian cluster/sector and disaggregated by administrative division?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('affected area',input.preferred_tags) > -1",
                              radioButtons("affected_area_subquestion1",
                                           "Are the data vector or tabular by administrative division which describe
                                           the type and/or severity of impacts geographically?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('damaged buildings',input.preferred_tags) > -1",
                              radioButtons("damaged_buildings_subquestion1",
                                           "Are the data vector data with locations of damaged/destroyed buildings and an
                                           indication of damage level OR tabular data indicating percentage or total number
                                           of buildings in each damage category by administrative division?",
                                           c("yes","no"))),
             conditionalPanel("$.inArray('humanitarian access',input.preferred_tags) > -1",
                              radioButtons("humanitarian_access_subquestion1",
                                           "Are the data tabular or vector describing the location of natural hazards, permissions,
                                           active fighting, or other access constraints that impact the delivery of 
                                           humanitarian interventions?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('obstacles',input.preferred_tags) > -1 || $.inArray('transportation status',input.preferred_tags) > -1",
                              radioButtons("transportation_status_subquestion1",
                                           "Are the data tabular or vector representing local transportation routes with an indication
                                           of status or practicability?",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('casualties',input.preferred_tags) > -1 || $.inArray('fatalities',input.preferred_tags) > -1",
                              radioButtons("casualties_subquestion1",
                                           "Do the data describe number of deaths and/or persons injured, disaggregated by location?
                                           Values can be cumulative totals or a time series of new deaths and/or injured persons.",
                                           c("None selected","yes","no"))),
             conditionalPanel("$.inArray('missing persons',input.preferred_tags) > -1",
                              radioButtons("missing_persons_subquestion1",
                                           "Do the data describe the current number of people missing, disaggregated by location?",
                                           c("None selected","yes","no")))))),             
  
  sidebarPanel(width=4, h4("Comments: "), textOutput("comments")))
) # sidebarLayout


# SERVER ------------------------------------------------------------------

server <- function(input,output){

  # Part 1 Comments ---------------------------------------------------------
  
  output$comments <- renderText({
    
    p1_1 <- ""
    if(input$subnational == "no"){
      p1_1 <- "WARNING: Do NOT include dataset."
    }
    
  # Part 2 Comments ---------------------------------------------------------
    p2_1 <- ""
    p2_2 <- ""
    p2_3 <- ""
    p2_4 <- ""
    p2_5 <- ""
    
    if(input$tab_geo == "tabular"){
      if(input$fieldNames_dataRows == "no"){
        p2_1 <- "Dataset does not contain easy to determine field names and/or data rows."
      }
      if(input$file_format == "yes" & input$file_format == "yes" & input$subcat_tab == "no"){
        p2_2 <- "Data for sub-categories are not separated by tab."
      }
      if(input$location_coord == "yes"){
        if(!("decimal_form" %in% input$xy_conditions)){
          p2_3 <- "X and Y coordinates are not in decimal degree form."
        }
        if(!("two_columns" %in% input$xy_conditions)){
          p2_4 <- "X and Y coordinates are not separated into two columns."
        }
      }
    }
  
    if(input$tab_geo == "geographic"){
      if(input$geo_format %in% c("kml","kmz","geopackage")){
        p2_5 <- paste("The",input$geo_format,"format is not a preferred format.",sep=" ")
      }else if(input$geo_format == "raster"){
        p2_5 <- "WARNING: Do NOT include dataset due to raster format."
      }
    }
    
    # Part 3 Comments ---------------------------------------------------------
    p3_1 <- ""
    p3_2 <- ""
    
    if(input$locations_comparison == "yes" & 
       input$necessary_info == "no" & 
       input$missing_data_metadata == "data_not_collected")
    {
      p3_1 <- "Dataset does not appear to cover all admin X units and is therefore assumed to be incomplete."
    }
    
    if(input$locations_comparison == "no" & input$complete_as_possible == "no"){
      p3_2 <- "Dataset is not considered complete by its contributor."
    }
    # Part 4 Comments ---------------------------------------------------------
    p4_1 <- ""
    if(input$location_reference == "yes" & input$location_defined == "no" & input$location_join == "no"){
      p4_1 <- "Dataset is disaggregated using specific locations, but no corresponding joinable dataset defining those locations is available."
    }
    
    # Part 5 Comments ---------------------------------------------------------
    p5_1 <- ""
    if(input$disaggregated_level == "no" & input$levels != ""){
      p5_1 <- paste("Dataset is not disaggregated to the most commonly used level for this location ","(",input$levels,").",sep = "")
    }
    
    # Part 6 Comments ---------------------------------------------------------
    p6_1 <- ""
    # Administrative Divisions
    if("administrative divisions" %in% input$preferred_tags | 'common operational dataset - cod' %in% input$preferred_tags){
      if(input$admin_div == "no"){
        p6_1 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_2 <- ""
    if("populated places" %in% input$preferred_tags){
      if(input$populated_places == "no"){
        p6_2 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_3 <- ""
    if("roads" %in% input$preferred_tags | "transportation" %in% input$preferred_tags){
      if(input$roads == "no"){
        p6_3 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
      if(input$roads == "yes"){
        if(input$roads_subquestion1 == "no"){
          p6_3 <- "The dataset does not fit the official description for the dataset tag(s)."
        }
      }
    }
    p6_4 <- ""
    if("airports" %in% input$preferred_tags){
      if(input$airports_subquestion1 == "no"){
        p6_4 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
      if(input$airports_subquestion1 == "yes"){
        if(input$airports_subquestion2 == "no"){
          p6_4 <- "The dataset does not fit the official description for the dataset tag(s)."
        }
      }
    }
    p6_5 <- ""
    if("population statistics" %in% input$preferred_tags | "demographics" %in% input$preferred_tags){
      if(input$pop_stat_subquestion1 == "no"){
        p6_5 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_6 <- ""
    if("sex and age disaggregated data - sadd" %in% input$preferred_tags | "population statistics" %in% input$preferred_tags | "demographics" %in% input$preferred_tags){
      if(input$sadd_subquestion1 == "no"){
        p6_6 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_7 <- ""
    if("poverty" %in% input$preferred_tags){
      if(input$poverty_subquestion1 == "no"){
        p6_7 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_8 <- ""
    if("health facilities" %in% input$preferred_tags){
      if(input$healthfacilities_subquestion1 == "no"){
        p6_8 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_9 <- ""
    if("education facilities" %in% input$preferred_tags){
      if(input$educationfacilities_subquestion1 == "no"){
        p6_9 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_10 <- ""
    if("affected schools" %in% input$preferred_tags){
      if(input$affected_schools_subquestion1 == "no"){
        p6_10 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_11 <- ""
    if("integrated phase classification - ipc" %in% input$preferred_tags | "food security" %in% input$preferred_tags){
      if(input$food_security_subquestion1 == "no"){
        p6_11 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_12 <- ""
    if("global acute malnutrition - gam" %in% input$preferred_tags){
      if(input$gam_subquestion1 == "no"){
        p6_12 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_13 <- ""
    if("severe acute malnutrition - sam" %in% input$preferred_tags){
      if(input$sam_subquestion1 == "no"){
        p6_13 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_14 <- ""
    if("internally displaced persons - idp" %in% input$preferred_tags){
      if(input$idp_subquestion1 == "no"){
        p6_14 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_15 <- ""
    if("refugees" %in% input$preferred_tags | "persons of concern" %in% input$preferred_tags){
      if(input$refugees_subquestion1 == "no"){
        p6_15 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_16 <- ""
    if("returnees" %in% input$preferred_tags){
      if(input$returnees_subquestion1 == "no"){
        p6_16 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_17 <- ""
    if("who is doing what where - 3w" %in% input$preferred_tags){
      if(input$`3w_subquestion1` == "no"){
        p6_17 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_18 <- ""
    if("affected area" %in% input$preferred_tags){
      if(input$affected_area_subquestion1 == "no"){
        p6_18 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_19 <- ""
    if("damaged buildings" %in% input$preferred_tags){
      if(input$damaged_buildings_subquestion1 == "no"){
        p6_19 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_20 <- ""
    if("humanitarian access" %in% input$preferred_tags){
      if(input$humanitarian_access_subquestion1 == "no"){
        p6_20 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_21 <- ""
    if("obstacles" %in% input$preferred_tags | "transportation status" %in% input$preferred_tags){
      if(input$transportation_status_subquestion1 == "no"){
        p6_21 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_22 <- ""
    if("casualities" %in% input$preferred_tags | "fatalities" %in% input$preferred_tags){
      if(input$casualties_subquestion1 == "no"){
        p6_22 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    p6_23 <- ""
    if("missing persons" %in% input$preferred_tags){
      if(input$missing_persons_subquestion1 == "no"){
        p6_23 <- "The dataset does not fit the official description for the dataset tag(s)."
      }
    }
    ##### Output comments from all parts
    paste(p1_1,p2_1,p2_2,p2_3,p2_4,p2_5,p3_1,p3_2,p4_1,p5_1,p6_1,p6_2,p6_3,p6_4,p6_5,
          p6_6,p6_7,p6_8,p6_9,p6_10,p6_11,p6_12,p6_13,p6_14,p6_15,p6_15,p6_16,
          p6_17,p6_18,p6_19,p6_20,p6_21,p6_22,p6_23,sep=" ")
    
  })
  
}

shinyApp(ui=ui,server=server)





