# PSConnClass.R
#
# R6 class describing a PowerSchool connection

PSCONN = R6Class(
  
  #### CLASSNAME ####
  classname = "PSCONN",
  
  #### PRIVATE LIST ####
  private = list(
    
    # Private Variables #
    school.site   = NULL,  # powerschool subdomain (like "greentechhigh")
    client.ID     = NULL,  # From the plugin management page
    client.secret = NULL,  # From the plugin management page
    auth.basic    = NULL,  # base 64 encoded string of the above
    auth.bearer   = NULL,  # authentication token
    has.login     = FALSE, # TRUE when authentication token is valid
    
    # Private Functions #
    site = function() {  
      # Returns API base URL as a string
      return(paste0("https://", self$school.site, ".powerschool.com/"))
    },
    
    update.file = function() {
      # Updates the credentials file to match current settings
      line1 <- '# credentials.R'
      line2 <- ''
      line3 <- '# Holds credential information for RPSpreview'
      line4 <- ''
      line5 <- paste0("credentials = list(schoolSite = '", private$school.site, "',")
      line6 <- paste0("client.ID = '", private$client.ID,"',")
      line7 <- paste0("client.secret = '", private$client.secret,"',")
      line8 <- paste0("auth.basic = '", private$auth.basic,"',")
      line9 <- paste0("auth.bearer = '", private$auth.bearer,"')")
      
      cat(line1, line2, line3, line4, line5, line6, line7, line8, line9, file='credentials.R', sep='\n')
    }
  ), # private
  
  #### PUBLIC LIST ####
  public = list(
    
    # Setup functions
    initialize = function() {
      # Constructor function  
      source("credentials.R")
      
      private$school.site   <- credentials$schoolSite
      private$client.ID     <- credentials$client.ID
      private$client.secret <- credentials$client.secret
      private$auth.basic    <- credentials$auth.basic
      private$auth.bearer   <- credentials$auth.bearer
      private$has.login     <- TRUE
    },
    
    check.API = function() {
      # checks that API is responding agnostic of authentication
      tURL = paste0(self$get.site(),"ws/v1/time")
      tResp = GET(url=tURL)
      if (tResp$status_code != 200) {
        print("The API is not responding properly. You should not continue.")
      }
      else {
        print("The API is responding.")
      }
    },
    
    check.login = function() {
      # Checks state of login credentials and makes them current
      if (self$isLoggedIn() == TRUE) {
        print("Checking current login credentials")
        
        testURL = paste0(self$get.site(),"ws/v1/school/1/student/count")
        
        resp = GET(url=testURL,
                   add_headers(.headers = c(Authorization=paste0("Bearer ", self$get.authBearer()))),
                   accept_xml())
        
        if (resp$status_code == 200) {
          self$set.loggedIn(TRUE)
          print("Logged in successfully.")
          self$update()
          return()
        }
        else {
          self$set.loggedIn(FALSE)
          print("Login unsuccessful. Trying again.")
          self$check.login()
        }
      }
      
      else {
        print("Not logged in yet.")
        print("Generating authentication string")
        self$set.authBasic(base64encode(what=charToRaw(paste0(self$get.clientID(),":",self$get.clientSecret()))))
        print(paste0("Generated Authentication string: ",self$get.authBasic()))
        
        print("Retrieving new access token")
        oauthStub = paste0(self$get.site(),"oauth/access_token/")
        print(oauthStub)
        
        resp = POST(url=oauthStub,
                    add_headers(.headers = c(Authorization=paste0("Basic ", self$get.authBasic()))),
                    content_type("application/x-www-form-urlencoded;charset=UTF-8"),
                    body=list(grant_type="client_credentials"),
                    encode="form")
        
        self$set.authBearer(content(resp)$access_token)
        self$set.loggedIn(TRUE)
        print(paste0("Retrieved Access Token: ", self$get.authBearer()))
        self$check.login()		
      }
    },
    
    # Internal access functions
    get.school = function() { return(private$school.site)},
    get.site = function() { return(paste0("https://", private$school.site, ".powerschool.com/"))},
    get.clientID = function() { return(private$client.ID) },
    get.clientSecret = function() { return(private$client.secret) },
    get.authBasic = function() { return(private$auth.basic) },
    get.authBearer = function() { return(private$auth.bearer) },
    isLoggedIn = function() { return(private$has.login)},
    
    set.school = function(school) { private$school.site <- school },
    set.clientID = function(ID) { private$client.ID <- ID },
    set.clientSecret = function(secret) { private$client.secret <- secret },
    set.authBasic = function(basic) { private$auth.basic <- basic },
    set.authBearer = function(bearer) { private$auth.bearer <- bearer },
    set.loggedIn = function(boo = FALSE) {private$has.login <- boo },
    update = function() { private$update.file() },
    
    # Data access functions
    all.students = function() {
      aURL = paste0(self$get.site(),"ws/v1/school/1/student/?pagesize=1000")
      
      ASResp = GET(url=aURL,
                   add_headers(.headers = c(Authorization=paste0("Bearer ",self$get.authBearer()))),
                   accept_xml())
      students = xmlParse(rawToChar(ASResp$content))
      return(students)
    }
  ) # public
)