FROM mcr.microsoft.com/dotnet/core/sdk:2.1.603-stretch as builder
RUN apt-get update && apt-get install -y ca-certificates
WORKDIR /app

COPY ./src.csproj /app/
RUN dotnet restore
COPY . .
RUN dotnet publish --output /out/ --configuration Release

FROM mcr.microsoft.com/dotnet/core/runtime:2.1.10-stretch-slim

WORKDIR /app

COPY --from=builder /out /app

ENTRYPOINT ["dotnet", "src.dll"]

