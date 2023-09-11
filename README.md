# Collaborative News

Collaborative News is a web platform for news sharing where you can also interact with other users.

## Project Components

* [ER: Requirements Specification](ER.md)
* [EBD: Database Specification](EBD.md)
* [EAP: Architecture Specification and Prototype](EAP.md)
* [PA: Product and Presentation](PA.md)

## Artefacts Checklist

* The artefacts checklist is available at: [link](https://docs.google.com/spreadsheets/d/1ZYTvlofQVjFsRi0uJBWCdCignXMlEEqJ-sQ_YFjHyHw/edit)

## Product

### Usage

The URL to the product is: http://lbaw2103.lbaw.fe.up.pt  

#### Administration Credentials

Administration URL: http://lbaw2103.lbaw.fe.up.pt/admin/users 

| Username | Password |
| -------- | -------- |
| admin@fe.up.pt    | admin123 |

#### User Credentials

| Type          | Username  | Password |
| ------------- | --------- | -------- |
| basic account | collab@fe.up.pt    | collab123 |
| news writer/editor   | newseditor@fe.up.pt    | newsed123 |

### Installation

The final version of the source code is available [here](https://git.fe.up.pt/lbaw/lbaw2122/lbaw2103/-/tree/PA). 

Docker commands to start the image:

```
docker run -it -p 8000:80 --name=lbaw2103 -e DB_DATABASE="lbaw2103" -e DB_SCHEMA="lbaw2103" -e DB_USERNAME="lbaw2103" -e DB_PASSWORD="DIgnbUzo" git.fe.up.pt:5050/lbaw/lbaw2122/lbaw2103
```

## Team

* Diogo Pinto, up201906067@up.pt
* Guilherme Garrido, up201905407@up.pt
* Luís Lucas, up201904624@up.pt
* Pedro Pinheiro, up201906788@up.pt

***
GROUP2103, 28/01/2022
