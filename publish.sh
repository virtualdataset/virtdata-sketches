#!/bin/bash
if (( $(git status --porcelain 2>/dev/null| wc -l) > 0 ))
then
 printf "Unchanged files are present. Please clean up your working tree first.\n" ;
 git status
 exit 2
fi
rm -rf docs
mdbook build
mv book docs
echo "sketch.virtdata.io" > docs/CNAME
git add docs
git commit -m'publishing docs'
git push
