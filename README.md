# CMIS 1.1 compliant opencmis server

## Docker
docker build -t opencmis .
docker run -p 9000:8080 opencmis
```
## How to use it
### CMIS 1.1
WS (SOAP) Binding: http://localhost:9000/opencmis/services11/cmis?wsdl
AtomPub Binding: http://localhost:9000/opencmis/atom11
Browser Binding: http://localhost:9000/opencmis/browser

### CMIS 1.0
WS (SOAP) Binding: http://localhost:9000/opencmis/services/cmis?wsdl
AtomPub Binding: http://localhost:9000/opencmis/atom

### Authentication
Basic Authentication 

Default test user :
test/test