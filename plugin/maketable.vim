function! s:makeTable(bang, line1, line2, ...)
  let sep = get(a:000, 0, ',')
  let ncols = 0
  let rows = map(map(range(a:line1, a:line2), 'getline(v:val)'), 'split(v:val, sep)')
  if len(rows) <= 1 && len(rows[0]) == 1 && rows[0][0] == ''
    return
  endif
  let w = []
  for row in rows
    let ncol = len(row)
    if ncol > ncols
      let ncols = ncol
    endif
  endfor
  for n in range(len(rows))
    let rows[n] = map(rows[n], "substitute(v:val, '^\\s\\+\\|\\s\\+$', '', 'g')")
    \ + repeat([""], ncols - len(rows[n]))
  endfor
  let h = range(len(rows[0]))
  for c in range(len(rows[0]))
    let m = 0
    let w = range(len(rows))
    for r in range(len(w))
      let w[r] = strdisplaywidth(rows[r][c])
      let m = max([m, w[r]])
    endfor
    for r in range(len(w))
      let rows[r][c] = rows[r][c] . repeat(' ', m - w[r])
    endfor
    let h[c] = repeat('-', strdisplaywidth(rows[0][c]))
  endfor
  for n in range(len(rows))
    let rows[n] = '|' . join(rows[n], '|') . '|'
  endfor
  let pos = getpos('.')
  silent exe printf('%d,%dd _', a:line1, a:line2)
  if a:bang =~ '!'
    call insert(rows, '|' . join(h, '|') . '|', 1)
  else
    call insert(rows, '|' . join(h, '|') . '|', 0)
    call insert(rows, '|' . substitute(join(h, '|'), '-', ' ', 'g') . '|', 0)
  endif
  silent call append(a:line1-1, rows)
  call setpos('.', pos)
endfunction

function! s:unmakeTable(...)
  let sep = get(a:000, 0, ',')
  let start = search('^$', 'bcnW')
  let end = search('^$', 'ncW')
  if start == 0
    let start = 1
  else
    let start += 1
  endif
  if end == 0
    let end = line('$')
  else
    let end -= 1
  endif
  let lines = getline(start, end)
  let lines = filter(lines, {x-> v:val !~ '^|[-:|]\+|$'})
  let lines = map(lines, {_, x-> trim(substitute(v:val[1:-2], '\s*|\s*', sep, 'g'))})
  exe printf('%d,%d d_', start, end)
  silent put! =lines
endfunction

command! -bang -range -nargs=? MakeTable call s:makeTable("<bang>", <line1>, <line2>, <f-args>)
command! -bang -nargs=? UnmakeTable call s:unmakeTable(<f-args>)
