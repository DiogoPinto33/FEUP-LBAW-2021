# EAP: Architecture Specification and Prototype

Collaborative News is a web platform for news sharing where you can also interact with other users.

## A7: Web Resources Specification

In this artefact the resources to be used in the Collaborative News web application are defined and described, listing their properties using OpenAPI(YAML). 
CRUD(create, read, update, delete) operations are presented for each resource.

### 1. Overview

In this section, an overview of the web application is presented using modules to separate resources.

| Module | Description |
| ------- | ------------------------ |
| **M01: Authentication and Individual Profile** | Web resources associated with user authentication and individual profile management. Includes the following system features: login/logout, registration, view and edit personal profile information, follow others and see notifications. |
| **M02: News, comments and votes** | Web resources associated with news items. Includes the following system features: create/edit/delete news, comments and votes, and view item details. |
| **M03: Detailed search and topics** | Web resources associated with searching methods and news topics. Includes the following system features: search for news using several filters, follow and propose topics. |
| **M04: User Administration and Static pages** | Web resources associated with user management, specifically: manage user accounts and topic proposals. Web resources with static content are associated with this module: about and help. |

### 2. Permissions

In this section, the permissions associated with web resources are presented.

| Identifier | Name | Description |
| ------- | ------ | ------------------------ |
| **PUB** | Public | Users without privileges |
| **USR** | User | Authenticated users |
| **OWN** | Owner | Authenticated users with editing privileges over his posts |
| **ADM** | Administrator | System administrators |

### 3. OpenAPI Specification

OpenAPI specification in YAML format to describe the web application's web resources.

[a7_openapi.yaml](a7_openapi.yaml)

```yaml
openapi: 3.0.0

info:
  version: '1.0'
  title: 'LBAW Collaborative News Web API'
  description: 'Web Resources Specification (A7) for Collaborative News'

servers:
- url: http://lbaw2103.lbaw.fe.up.pt/
  description: Production server

externalDocs:
  description: Find more info here.
  url: https://git.fe.up.pt/lbaw/lbaw2122/lbaw2103

tags:
  - name: 'M01: Authentication and Individual Profile'
  - name: 'M02: News, comments and votes'
  - name: 'M03: Detailed search and topics'
  - name: 'M04: User Administration and Static pages'

paths:
 /login:
  get:
    operationId: R101
    summary: 'R101: Login Form'
    description: 'Provide login form. Access: PUB'
    tags:
      - 'M01: Authentication and Individual Profile'
    responses:
      '200':
        description: 'Ok. Show UI15'

  post:
    operationId: R102
    summary: 'R102: Login Action'
    description: 'Processes the login form submission. Access: PUB'
    tags:
      - 'M01: Authentication and Individual Profile'

    requestBody:
      required: true
      content:
        application/x-www-form-urlencoded:
          schema:
            type: object
            properties:
              username:
                type: string
              password:
                type: string
            required:
                - username
                - password

    responses:
     '302':
      description: 'Redirect after processing the sign in credentials.'
      headers:
        Location:
         schema:
          type: string
         examples:
            302Success:
             description: 'Successful authentication. Redirect to Homepage.'
             value: '/news'
            302Error:
              description: 'Failed authentication. Redirect to login form.'
              value: '/login'

 /logout:
    post:
      operationId: R103
      summary: 'R103: Logout Action'
      description: 'Logout the current authenticated used. Access: USR, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      responses:
        '302':
          description: 'Redirect after processing logout.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful logout. Redirect to home page.'
                  value: '/news'
                302Error:
                  description: 'Failed to logout.'
                  value: '/news'

 /sign_up:
    get:
      operationId: R104
      summary: 'R104: Sign Up Form'
      description: 'Provide new user sign up form. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'

      responses:
        '200':
          description: 'Ok. Show UI16'

    post:
      operationId: R105
      summary: 'R105: Sign Up Action'
      description: 'Processes the new user sign up form submission. Access: PUB'
      tags:
        - 'M01: Authentication and Individual Profile'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
                email:
                  type: string
                description:
                  type: string
                image:
                  type: string
                  format: binary
              required:
                - username
                - password
                - email

      responses:
        '302':
          description: 'Redirect after processing the new user information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful authentication. Redirect to homepage.'
                  value: '/news'
                302Failure:
                  description: 'Failed authentication. Redirect to sign up page.'
                  value: '/sign_up'

 /users/{id_user}:
    get:
      operationId: R106
      summary: 'R106: View User Profile'
      description: 'Show the individual user profile. Access: USR, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show UI13'
        '404':
          description: 'Not Found.'

 /users/{id_user}/edit:
    get:
      operationId: R107
      summary: 'R107: Edit Profile Form'
      description: 'Provide Edit Profile Form. Access: OWN, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Show form to edit profile'
          
    post:
      operationId: R108
      summary: 'R108: Edit Profile Action'
      description: 'Processes Edit Profile Form. Access: OWN, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'
      
      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
                description:
                  type: string
                image:
                  type: string
                  format: binary
              required:
                - username
                - password
      responses:
        '302':
         description: 'Redirect after processing the profile edition form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The profile edition was successful. Redirect to user profile.'
                 value: '/user/{id_user}'
               302Error:
                 description: 'Failed to edit profile. Redirect to profile form edition.'
                 value: '/user/{id_user}/edit'

 /users/{id_user}/delete:      
    delete:
      operationId: R109
      summary: 'R109: Delete Account'
      description: 'Delete account. Access: OWN, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok'
        '404':
          description: 'Not found'

 /users/{id_user}/follow:
   put:
     operationId: R110
     summary: 'R110: Follow user'
     description: 'Follow a user. Access: USR'
     tags:
       - 'M01: Authentication and Individual Profile'

     parameters:
       - in: path
         name: id_user
         schema:
            type: integer
         required: true

     responses:
       '200':
         description: 'Ok.'
       '401':
          description: 'Unauthorized'

   delete:
     operationId: R111
     summary: 'R111: Unfollow user'
     description: 'Unfollow a user. Access: USR'
     tags:
       - 'M01: Authentication and Individual Profile'

     parameters:
       - in: path
         name: id_user
         schema:
            type: integer
         required: true

     responses:
       '200':
         description: 'Ok.'
       '401':
          description: 'Unauthorized'

 /users/{id_user}/notifications:
    get:
      operationId: R112
      summary: 'R112: View User Notifications'
      description: 'Show the notifications of an individual user. Access: USR, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show UI13, user notifications'
          content:
            application/json:
                schema:
                    type: array
                    items:
                        type: object
                        properties:
                           id:
                             type: integer
                           content:
                             type: string
                           date:
                             type: date
        '403':
          description: 'Forbidden'
        '404':
          description: 'Not Found'

    delete:
      operationId: R113
      summary: 'R113: Delete Notification'
      description: 'Delete notification. Access: ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      parameters:
        - in: path
          name: id_user
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Notification deleted'
        '403':
          description: 'Forbidden'
        '404':
          description: 'Not Found'

 /news:
    get:
      operationId: R201
      summary: 'R201: Initial page news'
      description: 'Processes the user preferences and return an initial page. Not authenticated receive default page. Access: PUB, USR'
      tags:
        - 'M02: News, comments and votes'
        
      responses:
        '200':
          description: 'Ok. Show UI01.'
          content:
            application/json:
              schema:
                type: array
                items: 
                  type: object
                  properties:
                    title:
                      type: string
                    content:
                      type: string
                    image:
                      type: string
                      format: binary
                    date:
                      type: date 
                    topic:
                      type: string
                      
 /news/create:
    get:
      operationId: R202
      summary: 'R202: Create News Form'
      description: 'Provide the news form to a user. Access: USR'
      tags:
        - 'M02: News, comments and votes'
        
      responses:
        '200':
          description: 'Show form to write a news.'
          
    post:
      operationId: R203
      summary: 'R203: Create News Action'
      description: 'Processes the news form submission. Access: USR'
      
      tags:
        - 'M02: News, comments and votes'
        
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                title:
                  type: string
                content:
                  type: string
                topic:
                  type: array
                  items:
                    type: string
                image:
                  type: string
                  format: binary
            required:
                - title
                - content
                - topic
                
      responses:
       '302':
         description: 'Redirect after processing the news form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The news was created successfully. Redirect to initial page.'
                 value: '/news'
               302Error:
                 description: 'Failed to create a news. Redirect to news form.'
                 value: '/news/create'     
                 
 /news/{id_news}:
    get:
      operationId: R204
      summary: 'R204: News Details'
      description: 'News Details Page. Access: PUB, USR'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true

      responses:
        '200':
          description: 'Ok. Show UI10.'
          content:
            application/json:
              schema:
                type: object
                properties:
                  title:
                    type: string
                  content:
                    type: string
                  topic:
                    type: array
                    items:
                      type: string
                  image:
                    type: string
                    format: binary
                  date:
                    type: date 
                  reputation:
                    type: integer
                  writer:
                    type: string
                    
    delete:
      operationId: R205
      summary: 'R205: Delete news'
      description: 'Delete a news. Access: OWN, ADM'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      responses:
        '302':
         description: 'Redirect after processing the news form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The news was deleted successfully. Redirect to homepage.'
                 value: '/news'
               302Error:
                 description: 'Failed to delete the news. Redirect to the news page.'
                 value: '/news/{id_news}'
                 
 /news/{id_news}/edit:
    get:
      operationId: R206
      summary: 'R206: Edit News Form'
      description: 'Provide the news form to a user for edition. Access: OWN, ADM'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      responses:
        '200':
          description: 'Show form to edit a news.'
          
    post:
      operationId: R207
      summary: 'R207: Edit News Action'
      description: 'Processes the news form edition submission. Access: OWN, ADM'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                title:
                  type: string
                content:
                  type: string
                topic:
                  type: array
                  items:
                    type: string
                image:
                  type: string
                  format: binary
            required:
                - title
                - content
                - topic
      responses:
       '302':
         description: 'Redirect after processing the news form edition.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The news edition was successful. Redirect to initial page.'
                 value: '/news/{id_news}'
               302Error:
                 description: 'Failed to edit the news. Redirect to news form edition.'
                 value: '/news/{id_news}/edit'

 /news/{id_news}/create_comment:
    get:
      operationId: R208
      summary: 'R208: Comment Form'
      description: 'Provide the comment form to a user. Access: USR'
      tags:
        - 'M02: News, comments and votes'
      
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      responses:
        '200':
          description: 'Show form to write a comment.'
          
    post:
      operationId: R209
      summary: 'R209: Comment Action'
      description: 'Processes the comment form submission. Access: USR'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                content:
                  type: string
                  
      responses:
       '302':
         description: 'Redirect after processing the comment form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The comment was created successfully. Redirect to the news page.'
                 value: '/news/{news_id}'
               302Error:
                 description: 'Failed to create the comment. Redirect to the news page.'
                 value: '/news/{news_id}'

 /news/{id_news}/edit_comment:
   get:
     operationId: R210
     summary: 'R210: Edit Comment Form'
     description: 'Provide the comment form to a user for edition. Access: OWN, ADM'
     tags:
        - 'M02: News, comments and votes'
        
     parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
     responses:
        '200':
          description: 'Show form to edit a comment.'
          
   post:
      operationId: R211
      summary: 'R211: Edit Comment Action'
      description: 'Processes the comment form edition submission. Acess: OWN, ADM'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                content:
                  type: string
                  
      responses:
        '302':
          description: 'Redirect after processing the comment form edition.'
          headers:
            Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The comment edition was successful. Redirect to the news page.'
                 value: '/news/{news_id}'
               302Error:
                 description: 'Failed to edit the comment. Redirect to the news page.'
                 value: '/news/{news_id}'


 /news/{id_news}/delete_comment:
    delete:
      operationId: R212
      summary: 'R212: Delete comment'
      description: 'Delete a comment. Access: OWN, ADM'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      responses:
        '302':
         description: 'Redirect after processing the comment form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'The comment was deleted successfully. Redirect to the news page.'
                 value: '/news/{news_id}'
               302Error:
                 description: 'Failed to delete the comment. Redirect to the news page.'
                 value: '/news/{news_id}'

 /news/{id_news}/vote_on_news:
    put:
      operationId: R213
      summary: 'R213: Vote on news'
      description: 'Vote on news. Access: USR'
      tags:
       - 'M02: News, comments and votes'
       
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
          
      responses:
        '200':
          description: 'The vote was added successfully.'
        '401':
          description: 'Unauthorized'

    delete:
      operationId: R214
      summary: 'R214: Remove vote on news'
      description: 'Remove vote on news. Access: OWN'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
      responses:
        '200':
          description: 'The vote was removed successfully.'
        '401':
          description: 'Unauthorized'

 /news/{id_news}/vote_on_comment/{id_comment}:
    put:
      operationId: R215
      summary: 'R215: Vote on comment'
      description: 'Vote on comment. Access: USR'
      tags:
       - 'M02: News, comments and votes'
       
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
        - in: path
          name: id_comment
          schema:
            type: integer
          required: true
          
      responses:
        '200':
          description: 'The vote was added successfully.'
        '401':
          description: 'Unauthorized'
    
    delete:
      operationId: R216
      summary: 'R216: Remove vote on comment'
      description: 'Remove vote on comment. Access: OWN'
      tags:
        - 'M02: News, comments and votes'
        
      parameters:
        - in: path
          name: id_news
          schema:
            type: integer
          required: true
        - in: path
          name: id_comment
          schema:
            type: integer
          required: true
            
      responses:
        '200':
          description: 'The vote was removed successfully.'
        '401':
          description: 'Unauthorized'
          
 /news/search_exact:
   get:
     operationId: R301
     summary: 'R301: Exact Match Search'
     description: 'Search for specific news posts using text. Access: USR'
     tags:
       - 'M03: Detailed search and topics'

     parameters:
       - in: query
         name: string
         description: 'String to use for exact match search'
         schema:
            type: string
         required: true

     responses:
       '200':
         description: 'Ok. Show UI11'
         content:
            application/json:
                schema:
                    type: array
                    items:
                        type: object
                        properties:
                            title:
                              type: string
                            content:
                              type: string
                            image:
                              type: string
                              format: binary
                            date:
                              type: date 
                            writer:
                              type: string
                            topic:
                              type: array
                              items:
                                type: string
                              
       '400':
         description: Bad Request

 /news/search:
    get:
      operationId: R302
      summary: 'R302: Full-text Search'
      description: 'Search for news posts using text. Access: USR'
      tags:
       - 'M03: Detailed search and topics'

      parameters:
       - in: query
         name: string
         description: String to use for full-text search
         schema:
            type: string
         required: true

      responses:
       '200':
         description: 'Ok. Show UI11'
         content:
            application/json:
                schema:
                    type: array
                    items:
                        type: object
                        properties:
                           title:
                             type: string
                           content:
                             type: string
                           image:
                             type: string
                           date:
                             type: date
                           writer:
                             type: string
                           topic:
                             type: array
                             items:
                               type: string
       '400':
         description: Bad Request

 /news/topic/{id_topic}:
   get:
     operationId: R303
     summary: 'R303: Search by topic'
     description: 'Search for news with a certain topic. Access: USR'
     tags:
       - 'M03: Detailed search and topics'

     parameters:
       - in: query
         name: id_topic
         schema:
            type: integer
         required: true

     responses:
       '200':
         description: 'Ok. Show UI11'
         content:
            application/json:
                schema:
                    type: array
                    items:
                        type: object
                        properties:
                           title:
                             type: string
                           content:
                             type: string
                           image:
                             type: string
                           date:
                             type: date
                           writer:
                             type: string
                           topic:
                             type: array
                             items:
                               type: string

 /news/topic/{id_topic}/follow:
   put:
     operationId: R304
     summary: 'R304: Follow topic'
     description: 'Follow a topic. Access: USR'
     tags:
       - 'M03: Detailed search and topics'

     parameters:
       - in: path
         name: id_topic
         schema:
            type: integer
         required: true

     responses:
       '200':
         description: 'Ok.'
       '401':
          description: 'Unauthorized'

   delete:
     operationId: R305
     summary: 'R305: Unfollow topic'
     description: 'Unfollow a topic. Access: USR'
     tags:
       - 'M03: Detailed search and topics'

     parameters:
       - in: query
         name: id
         description: Identifier of the topic
         schema:
            type: integer
         required: true

     responses:
       '200':
         description: 'Ok.'
       '401':
          description: 'Unauthorized'

 /news/topic/propose_topic:
    get:
      operationId: R306
      summary: 'R306: New Topic Form'
      description: 'Provide the topic proposal form to a user. Access: USR'
      tags:
        - 'M03: Detailed search and topics'
      responses:
        '200':
          description: 'Ok.'
    post:
      operationId: R307
      summary: 'R307: Process topic form'
      description: 'Processes the topic proposal form submission. Access: USR'
      tags:
        - 'M03: Detailed search and topics'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                topic:
                  type: string
            required:
              - topic

      responses:
       '302':
         description: 'Redirect after processing the topic proposal form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'Success on proposing the topic. Redirect to topic page.'
                 value: '/news/topic'
               302Error:
                 description: 'Failed to propose topic. Redirect to topic page.'
                 value: '/news/topic'

 /about:
    get:
      operationId: R401
      summary: 'R401: View About Page'
      description: "Show About page. Access: PUB"
      tags:
        - 'M04: User Administration and Static pages'

      responses:
        '200':
          description: 'Ok. Show UI02'

 /help:
    get:
      operationId: R402
      summary: 'R402: View Help Page'
      description: "Show Help page. Access: PUB"
      tags:
        - 'M04: User Administration and Static pages'

      responses:
        '200':
          description: 'Ok. Show UI03'

 /admin/users:
    get:
      operationId: R403
      summary: 'R403: View Users Management Page'
      description: "View Users Management Page. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'

      responses:
        '200':
          description: 'Ok. Show UI17'
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: integer
                    username:
                      type: string
                    email:
                      type: string
                    reputation:
                      type: integer
        '403':
          description: 'Forbidden'


 /admin/users/create:
    get:
      operationId: R404
      summary: 'R404: User Creation Form'
      description: "User Creation Form. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'

      responses:
        '200':
          description: 'Ok. Show UI17, form to create a user.'

    post:
      operationId: R405
      summary: 'R405: User Creation Action'
      description: "Process User Creation Form. Access: ADM"
      tags:
        - 'M04: User Administration and Static pages'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
                email:
                  type: string
                description:
                  type: string
                image:
                  type: string
                  format: binary
                is_admin:
                  type: integer

            required:
                - username
                - password
                - email
                - is_admin

      responses:
       '302':
         description: 'Redirect after processing the user creation form.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'User was created successfully. Redirect to admin page.'
                 value: '/admin/users'
               302Error:
                 description: 'Failed to create user. Redirect to user creation form .'
                 value: '/admin/users/create'

 /admin/users/search:
   get:
     operationId: R406
     summary: 'R406: User Search'
     description: 'Search for users. Access: ADM'
     tags:
       - 'M04: User Administration and Static pages'

     parameters:
       - in: query
         name: string
         description: 'String to use for user search'
         schema:
            type: string
         required: true

     responses:
       '200':
         description: 'Ok. Show UI17'
         content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id:
                      type: integer
                    username:
                      type: string
                    email:
                      type: string
                    reputation:
                      type: integer
       '400':
         description: Bad Request
         
 /admin/topic_suggestions:
    put:
      operationId: R407
      summary: 'R407: Approve Topic Proposal'
      description: 'Accept topic suggested by a user. Access: ADM'
      tags:
       - 'M04: User Administration and Static pages'
          
      responses:
        '200':
          description: 'Topic added successfully.'
        '401':
          description: 'Unauthorized'

    delete:
      operationId: R408
      summary: 'R408: Decline Topic Proposal'
      description: 'Decline topic suggested by a user. Access: ADM'
      tags:
       - 'M04: User Administration and Static pages'
          
      responses:
        '200':
          description: 'Topic removed successfully.'
        '401':
          description: 'Unauthorized'

```

---


## A8: Vertical prototype

In this artefact we include the implementation of the features that were considered necessary, aiming to endorse the presented composition and to get familiar with the technologies used.

### 1. Implemented Features

#### 1.1. Implemented User Stories
  
The user stories implemented in the prototype are identified in this section.

| User Story reference | Name                   | Priority                   | Description                   |
| -------------------- | ---------------------- | -------------------------- | ----------------------------- |
| US01 | Sign-up | High | As a Visitor, I want to sign-up so I can become a Member |
| US02 | Sign-in | High | As a Visitor, I want to sign-in to access my Member features |
| US06 | View news item | High | As a User, I want to view specific news item, so that I can access more information |
| US09 | Search for news items and comments | High | As a User, I want to search for specific posts, so that I can access what I’m looking for |
| US12 | Exact match search | Low | As a User, I want to search for specific posts, so that I can access what I’m looking for faster |
| US14 | Edit profile | High | As a Member, I want to edit my profile, so that I can present myself to other Members |
| US15 | View own profile | High | As a Member, I want to view my own profile, so that I can get to know how it looks like and see my reputation |
| US16 | View others users' profiles | High | As a Member, I want to view others Member's profiles, so that I can see their information and reputation |
| US19 | Create news item | High | As a Member, I want to create a news item, so that I can share it with other people |
| US28 | Edit news item | High | As a Writer, I want to edit my own news item, so that I keep them updated  |
| US29 | Delete news item | High | As a Writer, I want delete my own news items, so that I’m not sharing wrong information |
| US33 | Delete user accounts | High | As an Admin, I want to remove a user from the system, so that he can no longer access restricted content |
| US35 | Block user accounts | Medium | As an Admin, I want to block a user with low reputation, so that he can no longer access restricted content for a specific period of time |
| US36 | Unblock user accounts | Medium | As an Admin, I want to unblock a user, so that he can now access restricted content again |
| US38 | View Top News Feed | High | As a User, I want to view top news feed, so that I can see the trending and recent news on the feed |
| US39 | View User News Feed | High | As a Member, I want to view my news feed, so that I can see the news suggest to me on the feed |
| US40 | Administer User Accounts | Medium | As an Admin, I want to administer user accounts, so that I can search, view, edit, create and delete user accounts |

#### 1.2. Implemented Web Resources

The web resources implemented in the prototype are identified in this section. 

**Module M01: Authentication and Individual Profile**

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R101: Login Form        | GET [/login](http://lbaw2103.lbaw.fe.up.pt/login) |
| R102: Login Action      | POST /login |
| R103: Logout Action     | POST /logout |
| R104: Sign-up Form      | GET [/sign_up](http://lbaw2103.lbaw.fe.up.pt/register) |
| R105: Sign-up Action    | POST /sign_up|
| R106: View User Profile | GET [/users/{id_user}](http://lbaw2103.lbaw.fe.up.pt/users/1) |
| R107: Edit Profile Form | GET [/users/{id_user}/edit](http://lbaw2103.lbaw.fe.up.pt/users/1/edit) |
| R108: Edit Profile Action | POST /users/{id_user}/edit |

**Module M02: News, comments and votes**

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R201: Initial Page News  | GET [/news](http://lbaw2103.lbaw.fe.up.pt/news) |
| R202: Create News Form   | GET [/news/create](http://lbaw2103.lbaw.fe.up.pt/news/create) |
| R203: Create News Action | POST /news/create |
| R204: News Details       | GET [/news/{id_news}](http://lbaw2103.lbaw.fe.up.pt/news/1) |
| R205: Delete News        | DELETE /news/{id_news} |
| R206: Edit News Form     | GET [/news/{id_news}/edit](http://lbaw2103.lbaw.fe.up.pt/news/1/edit) |
| R207: Edit News Action   | POST /news/{id_news}/edit |


**Module M03: Detailed search and topics**

| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R301: Exact Match Search | GET [/news/search_exact](http://lbaw2103.lbaw.fe.up.pt/news/search?_token=RoyWju1zLRJcN5VBHtACN2kzYZfjeq5v3trHcocj&search=two) |
| R302: Full-text Search   | GET [/news/search](http://lbaw2103.lbaw.fe.up.pt/news/search_exact?_token=RoyWju1zLRJcN5VBHtACN2kzYZfjeq5v3trHcocj&search=ukraine) |

**Module M04: User Administration and Static pages**
  
| Web Resource Reference | URL                            |
| ---------------------- | ------------------------------ |
| R403: View Users Management Page | GET [/admin/users](http://lbaw2103.lbaw.fe.up.pt/admin/users) |
| R404: User Creation Form         | GET [/admin/users/create](http://lbaw2103.lbaw.fe.up.pt/admin/users/create) |
| R405: User Creation Action       | POST /admin/users/create |

### 2. Prototype

The prototype is available at http://lbaw2103.lbaw.fe.up.pt/

Credentials:

* admin user: admin@fe.up.pt/admin123
* regular user: collab@fe.up.pt/collab123

The code is available at https://git.fe.up.pt/lbaw/lbaw2122/lbaw2103

---


## Revision history

Changes made to the first submission:

1. Updated OpenAPI to match the current website.

***
GROUP2103, 03/01/2022

* Diogo Pinto, up201906067@up.pt
* Guilherme Garrido, up201905407@up.pt 
* Luís Lucas, up201904624@up.pt 
* Pedro Pinheiro, up201906788@up.pt (Editor)
