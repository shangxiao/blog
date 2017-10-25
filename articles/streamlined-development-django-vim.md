Streamlining your Development with Django & Vim
===============================================

25th October 2017

I currently have 2 effective development practices that I use regularly to speed up my TDD:


## 1. Auto run tests, manually save

Automatically trigger your django tests to run whenever a file is modified using [fswatch](https://github.com/emcrisostomo/fswatch):

```
fswatch . | xargs -n1 -I{} ./manage.py test -k
```


## 2. Auto save, manually run tests

In vim, you use the following [autocommand](http://vimdoc.sourceforge.net/htmldoc/autocmd.html) to "autosave":

```
:au TextChanged,TextChangedI <buffer> write
```

I have this conveniently mapped to a function key.  If for example you'd like to map it to F2, and have it toggle
on & off whenever F2 is pressed (by using the ! after au), place this in your `.vimrc`:

```
map <F2> :au! TextChanged,TextChangedI <buffer> write<CR>
```
