# Elastic APM startup hooks test

## Getting started

1. Run docker build in the root

   ```sh
   docker build -t startuphooks .
   ```

   This will build a docker image including the agent startup hooks version defined in the Dockerfile, which is 1.10.0. 

2. Run docker container

   ```sh
   docker run -it --rm \
   -p 5601:80 \
   -e ELASTIC_APM_SERVER_URLS=<APM server endpoint> \
   -e ELASTIC_APM_SECRET_TOKEN=<secret token> \
   startuphooks 
   ```

   where 
   - `<APM server endpoint>` is the APM server endpoint
   - `<secret token>` is the APM secret token

3. Make requests to

   ```
   curl http://localhost:5601/api/test
   curl -XPOST http://localhost:5601/api/test/exception -H 'Content-Length:0'
   ```

4. Observe that transactions are captured in APM UI, including the error for the /api/test/exception route.

## Referencing Elastic.Apm.* packages

If there is a need for the application to reference Elastic.Apm.* packages, for example, to create manual 
transactions and spans or reference additional packages, the Elastic.Apm.* package versions **must** match
the agent startup hooks version 