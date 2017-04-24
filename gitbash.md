git reset --hard origin/master //强制采用服务器版本

new folder:
git init
echo '# oracle-notes' >> README.md //新建
git add *.md
git commit -m 'initial commit by shums'
git remote add origin https://github.com/greenwichmt/oracle-notes.git
git push -u origin master

edit README.md
git add *.md
git commit -m 'modify frequently-used.sql'
git push