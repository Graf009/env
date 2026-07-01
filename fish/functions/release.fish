function release --description 'Sign and publish npm package'
    set VERSION (jq -r .version package.json)
    git add .
    git commit -S -m "Release $VERSION"
    git tag -s $VERSION -m $VERSION
    git push
end
