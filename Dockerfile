一个aspnet core runtime 环境下支持 FFMPEG 
请根据自己需要编写

FROM microsoft/dotnet:2.2-aspnetcore-runtime-stretch-slim AS base
WORKDIR /app
EXPOSE 80
ADD /ffmpeg-git-amd64-static.tar.xz /
RUN mv /ffmpeg*/ffmpeg /usr/bin/ && rm -rf /ffmpeg* 

FROM microsoft/dotnet:2.2-sdk-stretch AS build
WORKDIR /src
COPY ["Src/MicroServices/FileSvc/VideoSvc/VideoSvc.API/VideoSvc.API.csproj", "Src/MicroServices/FileSvc/VideoSvc/VideoSvc.API/"]
COPY ["Src/MicroServices/FileSvc/VideoSvc/VideoSvc.Domain/VideoSvc.Domain.csproj", "Src/MicroServices/FileSvc/VideoSvc/VideoSvc.Domain/"]
COPY ["Src/BuildBlocks/Microestc/Microestc/Microestc.csproj", "Src/BuildBlocks/Microestc/Microestc/"]
RUN dotnet restore "Src/MicroServices/FileSvc/VideoSvc/VideoSvc.API/VideoSvc.API.csproj"
COPY . .
WORKDIR "/src/Src/MicroServices/FileSvc/VideoSvc/VideoSvc.API"
RUN dotnet build "VideoSvc.API.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "VideoSvc.API.csproj" -c Release -o /app

FROM base AS runtime
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "VideoSvc.API.dll"]
