#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/sdk:6.0-windowsservercore-ltsc2022 AS base
WORKDIR /app
#EXPOSE 80
#EXPOSE 443
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["OpenShiftDotNetCoreTest.csproj", "."]
RUN dotnet restore "./OpenShiftDotNetCoreTest.csproj" -r win-x64
COPY . .
WORKDIR "/src/."
RUN dotnet build "OpenShiftDotNetCoreTest.csproj" -c Release -o /app/build -r win-x64 --self-contained false --no-restore

FROM build AS publish
RUN dotnet publish "OpenShiftDotNetCoreTest.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenShiftDotNetCoreTest.dll"]