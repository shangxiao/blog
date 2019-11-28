echo '# blog'
awk 'FNR==1 && NR>1{print "";print""}1' articles/*
