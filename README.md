# vim-maketable

![](http://i.imgur.com/joYGVe2.gif)

## Usage

Just select lines and do following

```
:'<,'>MakeTable
```

If you want to use first line as header of table, 

```
:'<,'>MakeTable!
```

If you want to use tab separated columns,

```
:'<,'>MakeTable! \t
```

If you want to make CSV from markdown table

```
:UnmakeTable
```

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)
