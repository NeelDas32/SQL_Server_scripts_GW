USE [master]
GO

CREATE DATABASE [GWRE_IT] ON  PRIMARY 
( NAME = N'GWRE_IT', FILENAME = N'D:\MSSQL\DATA\GWRE_IT.mdf' , SIZE = 5120MB , MAXSIZE = 25600MB, FILEGROWTH = 512MB )
 LOG ON 
( NAME = N'GWRE_IT_log', FILENAME = N'E:\MSSQL\LOG\GWRE_IT_log.ldf' , SIZE = 1024MB , MAXSIZE = 20480MB , FILEGROWTH = 1000MB )
GO

ALTER DATABASE [GWRE_IT] SET COMPATIBILITY_LEVEL = 100
GO

ALTER DATABASE [GWRE_IT] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [GWRE_IT] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [GWRE_IT] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [GWRE_IT] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [GWRE_IT] SET ARITHABORT OFF 
GO

ALTER DATABASE [GWRE_IT] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [GWRE_IT] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [GWRE_IT] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [GWRE_IT] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [GWRE_IT] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [GWRE_IT] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [GWRE_IT] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [GWRE_IT] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [GWRE_IT] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [GWRE_IT] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [GWRE_IT] SET  DISABLE_BROKER 
GO

ALTER DATABASE [GWRE_IT] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [GWRE_IT] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [GWRE_IT] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [GWRE_IT] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [GWRE_IT] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [GWRE_IT] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [GWRE_IT] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [GWRE_IT] SET  READ_WRITE 
GO

ALTER DATABASE [GWRE_IT] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [GWRE_IT] SET  MULTI_USER 
GO

ALTER DATABASE [GWRE_IT] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [GWRE_IT] SET DB_CHAINING OFF 
GO


