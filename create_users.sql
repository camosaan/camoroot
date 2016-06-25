#!/bin/bash
CREATE USER 'dbusername'@'localhost' IDENTIFIED BY 'dbuserpass';
CREATE DATABASE dbname;
USE dbusername;
GRANT ALL PRIVILEGES ON dbname.* TO 'dbusername'@'localhost';
EXIT

