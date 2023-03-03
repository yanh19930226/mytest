#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/In66.Web/In66.Web.csproj", "src/In66.Web/"]
RUN dotnet restore "src/In66.Web/In66.Web.csproj"
COPY . .
WORKDIR "/src/src/In66.Web"
RUN dotnet build "In66.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "In66.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "In66.Web.dll"]