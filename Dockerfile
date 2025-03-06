# 使用 Nginx 作为基础镜像
FROM nginx:alpine
LABEL authors="tudan"

# 复制 dist 目录到 Nginx 的静态文件目录
COPY dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
