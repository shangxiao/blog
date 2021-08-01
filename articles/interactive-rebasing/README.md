Slides for my talk on Interactive Rebasing with Git
===================================================

 - Intended to be viewed with vim, although any text based editor will do
 - Each slide is just a text file
 - The slide extension is sld for convenience in setting up a slide file type in
   vim with the following config:

```
" Slides
au BufRead,BufNewFile *.sld	set filetype=slide
au FileType slide setlocal nonumber noshowmode noruler noshowcmd nocursorline tw=100
au FileType slide map <Left> :bprev<CR>
au FileType slide map <Right> :bnext<CR>
```

 - Each slide is laid out with a terminal width of 100 chars in mind. To
   resize/scale the terminal use the title slide as the benchmark: ie open the
   first slide and/or resize the window or scale the font so that the heading
   sits roughly in the middle.
 - To present open a new vim session with `vim interactive-slides/000*.sld` so
   that all slides are loaded into buffers in order. Simply use the left & right
   arrow keys to navigate the slide deck.
