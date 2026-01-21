https://github.com/cicy-dev-002/cicy-remote.git 

所有仓库权限的 token: $GH_CICYBOT_TOKEN
you can use in curl call api control the github action workflow

git push dev-002 main 可以部署cicy-dev-002/cicy-remote的代码

现在需求是，你要触发一个github action ci,ci 在最后有一个loop，ci 运行时会安装cloudflared , 安装jupyter 安装 vnc novnc 并启动 vnc 的密码是 $JUPYTER_TOKEN

cloudflared 已经成功开启tunnel 下面几个域名会生效：

ga-ubuntu-3456.cicy.de5.net //electron-mcp/app rpc server
gau-ubuntu-8888.cicy.de5.net //jupyter
gau-6080.cicy.de5.net //novnc


验收标准：
上面三个域名可以 access
