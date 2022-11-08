function! s:makeTable(bang, line1, line2, ...)
  let l:sep = get(a:000, 0, ',')
  let l:ncols = 0
  let l:rows = map(map(range(a:line1, a:line2), 'getline(v:val)'), 'split(v:val, l:sep)')
  if len(l:rows) <= 1 && len(l:rows[0]) == 1 && l:rows[0][0] == ''
    return
  endif
  let l:w = []
  for l:row in l:rows
    let l:ncol = len(l:row)
    if l:ncol > l:ncols
      let l:ncols = l:ncol
    endif
  endfor
  for l:n in range(len(l:rows))
    let l:rows[l:n] = map(l:rows[l:n], "substitute(v:val, '^\\s\\+\\|\\s\\+$', '', 'g')")
    \ + repeat([''], l:ncols - len(l:rows[l:n]))
  endfor
  let l:h = range(len(l:rows[0]))
  for l:c in range(len(l:rows[0]))
    let l:m = 0
    let l:w = range(len(l:rows))
    for l:r in range(len(l:w))
      let l:w[l:r] = strdisplaywidth(l:rows[l:r][l:c])
      let l:m = max([l:m, l:w[l:r]])
    endfor
    for l:r in range(len(l:w))
      let l:rows[l:r][l:c] = l:rows[l:r][l:c] . repeat(' ', l:m - l:w[l:r])
    endfor
    let l:h[l:c] = repeat('-', strdisplaywidth(l:rows[0][l:c]))
  endfor
  for l:n in range(len(l:rows))
    let l:rows[l:n] = '|' . join(l:rows[l:n], '|') . '|'
  endfor
  let l:pos = getpos('.')
  silent exe printf('%d,%dd _', a:line1, a:line2)
  if a:bang =~ '!'
    call insert(l:rows, '|' . join(l:h, '|') . '|', 1)
  else
    call insert(l:rows, '|' . join(l:h, '|') . '|', 0)
    call insert(l:rows, '|' . substitute(join(l:h, '|'), '-', ' ', 'g') . '|', 0)
  endif
  silent call append(a:line1-1, l:rows)
  call setpos('.', l:pos)
endfunction

function! s:unmakeTable(...)
  let l:sep = get(a:000, 0, ',')
  let l:start = search('^$', 'bcnW')
  let l:end = search('^$', 'ncW')
  if l:start == 0
    let l:start = 1
  else
    let l:start += 1
  endif
  if l:end == 0
    let l:end = line('$')
  else
    let l:end -= 1
  endif
  let l:lines = getline(l:start, l:end)
  let l:lines = filter(l:lines, {x-> v:val !~ '^|[-:|]\+|$'})
  let l:lines = map(l:lines, {_, x-> trim(substitute(v:val[1:-2], '\s*|\s*', l:sep, 'g'))})
  exe printf('%d,%d d_', l:start, l:end)
  silent put! =l:lines
endfunction

command! -bang -range -nargs=? MakeTable call s:makeTable("<bang>", <line1>, <line2>, <f-args>)
command! -bang -nargs=? UnmakeTable call s:unmakeTable(<f-args>)
