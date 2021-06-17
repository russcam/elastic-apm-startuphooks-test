ARG AGENT_VERSION=1.10.0

# https://hub.docker.com/_/microsoft-dotnet-core
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
ARG AGENT_VERSION
WORKDIR /source

# install unzip for later use
RUN apt-get -y update && apt-get -yq install unzip

# copy csproj and restore as distinct layers
COPY *.sln .
COPY *.csproj .
RUN dotnet restore

# copy everything else and build app
COPY . .
RUN dotnet publish -c release -o /app --no-restore

# pull down the agent zip based on ${AGENT_VERSION} ARG
RUN curl -L -o ElasticApmAgent_${AGENT_VERSION}.zip https://github.com/elastic/apm-agent-dotnet/releases/download/${AGENT_VERSION}/ElasticApmAgent_${AGENT_VERSION}.zip && \
    unzip ElasticApmAgent_${AGENT_VERSION}.zip -d /ElasticApmAgent_${AGENT_VERSION}

# final stage/image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
ARG AGENT_VERSION
WORKDIR /app
COPY --from=build /app ./
COPY --from=build /ElasticApmAgent_${AGENT_VERSION} /ElasticApmAgent_${AGENT_VERSION}

ENV DOTNET_STARTUP_HOOKS=/ElasticApmAgent_${AGENT_VERSION}/ElasticApmAgentStartupHook.dll
ENV ELASTIC_APM_SERVICE_NAME=ElasticApmTestApi
ENV ELASTIC_APM_STARTUP_HOOKS_LOGGING=1
ENV ELASTIC_APM_LOG_LEVEL=trace

ENTRYPOINT ["dotnet", "Elastic.Apm.Test.Api.dll"]
