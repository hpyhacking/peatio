git stash -q --keep-index
echo 'running all tests...'
rspec spec
echo 'done'
RESULT=$?
git stash pop -q
[ $RESULT -ne 0 ] && exit 1
exit 0
