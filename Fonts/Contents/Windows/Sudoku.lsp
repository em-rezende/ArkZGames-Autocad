;; ======================================================================
;; SUDOKU.LSP - Jogo de Sudoku para AutoCAD - VERSÃO FINAL CORRIGIDA
;; ======================================================================
;; Início: 2025/12/16 - Ezequiel M Rezende
;; Com completa ajuda do DeepSeek

;; Variáveis globais de estado
(setq SD_dcl_id nil)
(setq SD_solution nil)      ;; Tabuleiro com solução completa
(setq SD_puzzle nil)        ;; Tabuleiro do jogo (com células vazias)
(setq SD_original nil)      ;; Tabuleiro original (para identificar células fixas)
(setq SD_game_active nil)
(setq SD_seed (getvar "DATE"))
(setq SD_start_time nil)
(setq SD_elapsed_time 0)
(setq SD_timer_active nil)
(setq SD_hints_remaining 3)
(setq SD_mistakes 0)
(setq SD_max_mistakes 3)
(setq SD_difficulty "medium")


;; Exibe a imagem (Slide) na DCL
(defun SD_ShowSld (tile slide color / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color) 
  (slide_image 0 0 x y
    (strcat "Sudoku" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ)
)
;; ======================================================================
;; FUNÇÕES AUXILIARES DE MANIPULAÇÃO DE LISTAS
;; ======================================================================

(defun SD_make_range (start end / result)
  (setq result nil)
  (while (<= start end)
    (setq result (cons end result))
    (setq end (1- end))
  )
  (reverse result)
)

(defun SD_drop (n lst)
  (cond
    ((<= n 0) lst)
    ((null lst) nil)
    (T (SD_drop (1- n) (cdr lst)))
  )
)

(defun SD_take (n lst)
  (cond
    ((<= n 0) nil)
    ((null lst) nil)
    (T (cons (car lst) (SD_take (1- n) (cdr lst))))
  )
)

(defun SD_update_cell (board row col value)
  (if (and board (< row (length board)) (< col (length (nth row board))))
    (progn
      (setq new_row 
        (append 
          (SD_take col (nth row board))
          (list value)
          (SD_drop (1+ col) (nth row board))
        )
      )
      
      (append 
        (SD_take row board)
        (list new_row)
        (SD_drop (1+ row) board)
      )
    )
    board
  )
)

(defun SD_get-cell (board row col) 
  (if (and board (< row (length board)) (>= row 0)
           (< col (length (nth row board))) (>= col 0))
      (nth col (nth row board))
      nil
  )
)

(defun SD_randnum (/ modulus multiplier increment)
  (setq modulus    65536
        multiplier 25173
        increment  13849)
  (setq SD_seed (rem (+ (* SD_seed multiplier) increment) modulus))
  (/ SD_seed modulus)
)

;; ======================================================================
;; FUNÇÕES DE VALIDAÇÃO DO SUDOKU
;; ======================================================================

(defun SD_is_valid_in_row (board row col value)
  (setq valid T)
  (setq col_list (SD_make_range 0 8))
  (foreach c col_list
    (if (and (/= c col) (= (SD_get-cell board row c) value))
      (setq valid nil)
    )
  )
  valid
)

(defun SD_is_valid_in_col (board row col value)
  (setq valid T)
  (setq row_list (SD_make_range 0 8))
  (foreach r row_list
    (if (and (/= r row) (= (SD_get-cell board r col) value))
      (setq valid nil)
    )
  )
  valid
)

(defun SD_is_valid_in_box (board row col value)
  (setq valid T)
  (setq box_row_start (* (fix (/ row 3)) 3))
  (setq box_col_start (* (fix (/ col 3)) 3))
  
  (setq row_list (SD_make_range box_row_start (+ box_row_start 2)))
  (setq col_list (SD_make_range box_col_start (+ box_col_start 2)))
  
  (foreach r row_list
    (foreach c col_list
      (if (and (/= r row) (/= c col) (= (SD_get-cell board r c) value))
        (setq valid nil)
      )
    )
  )
  valid
)

(defun SD_is_valid_move (board row col value)
  (and 
    (SD_is_valid_in_row board row col value)
    (SD_is_valid_in_col board row col value)
    (SD_is_valid_in_box board row col value)
  )
)

(defun SD_is_board_complete (board)
  (setq complete T)
  (setq row_list (SD_make_range 0 8))
  (setq col_list (SD_make_range 0 8))
  
  (foreach row row_list
    (foreach col col_list
      (setq value (SD_get-cell board row col))
      (if (or (null value) (= value 0))
        (setq complete nil)
        (if (not (SD_is_valid_move board row col value))
          (setq complete nil)
        )
      )
    )
  )
  complete
)

;; ======================================================================
;; FUNÇÕES DE GERAÇÃO DO TABULEIRO
;; ======================================================================

(defun SD_find_empty_cell (board / row col)
  (setq found nil)
  (setq row 0)
  (while (and (< row 9) (not found))
    (setq col 0)
    (while (and (< col 9) (not found))
      (setq value (SD_get-cell board row col))
      (if (or (null value) (= value 0))
        (setq found (list row col))
        (setq col (1+ col))
      )
    )
    (if (not found)
      (setq row (1+ row))
    )
  )
  found
)

(defun SD_generate_full_board ()
  ;; Tabuleiro Sudoku válido base
  (setq base_solution '(
    (5 3 4 6 7 8 9 1 2)
    (6 7 2 1 9 5 3 4 8)
    (1 9 8 3 4 2 5 6 7)
    (8 5 9 7 6 1 4 2 3)
    (4 2 6 8 5 3 7 9 1)
    (7 1 3 9 2 4 8 5 6)
    (9 6 1 5 3 7 2 8 4)
    (2 8 7 4 1 9 6 3 5)
    (3 4 5 2 8 6 1 7 9)
  ))
  base_solution
)

(defun SD_remove_cells (board difficulty / cells_to_remove cells_removed row col new_board)
  (setq cells_removed 0)
  (setq new_board board)
  
  (cond
    ((= difficulty "easy") (setq cells_to_remove 30))
    ((= difficulty "medium") (setq cells_to_remove 40))
    ((= difficulty "hard") (setq cells_to_remove 50))
    ((= difficulty "expert") (setq cells_to_remove 55))
    (T (setq cells_to_remove 40))
  )
  
  (while (< cells_removed cells_to_remove)
    (setq row (fix (* (SD_randnum) 9)))
    (setq col (fix (* (SD_randnum) 9)))
    (setq current_value (SD_get-cell new_board row col))
    
    (if (/= current_value 0)
      (progn
        (setq new_board (SD_update_cell new_board row col 0))
        (setq cells_removed (1+ cells_removed))
      )
    )
  )
  
  new_board
)

(defun SD_generate_puzzle ()
  (setq full_board (SD_generate_full_board))
  (setq puzzle (SD_remove_cells full_board SD_difficulty))
  (setq SD_solution full_board)
  (setq SD_puzzle puzzle)
  (setq SD_original puzzle)
)

;; ======================================================================
;; FUNÇÕES DE EXIBIÇÃO E CONTROLE
;; ======================================================================

(defun SD_update_display ()
  (setq row_list (SD_make_range 0 8))
  (setq col_list (SD_make_range 0 8))
  
  (foreach row row_list
    (foreach col col_list
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq puzzle_value (SD_get-cell SD_puzzle row col))
      (setq original_value (SD_get-cell SD_original row col))
      
      (if (and original_value (/= original_value 0))
        (progn
          (set_tile key (itoa original_value))
          (mode_tile key 1)
        )
        (progn
          (if (and puzzle_value (/= puzzle_value 0))
            (set_tile key (itoa puzzle_value))
            (set_tile key "")
          )
          (mode_tile key 0)
        )
      )
    )
  )
  
  (set_tile "hint_display" (strcat "Dicas: " (itoa SD_hints_remaining)))
  (set_tile "mistakes_display" (strcat "Erros: " (itoa SD_mistakes) "/" (itoa SD_max_mistakes)))
  
  (if SD_game_active
    (set_tile "status" "Jogo em andamento. Preencha todas as células corretamente.")
    (set_tile "status" "Clique em 'Novo Jogo' para começar.")
  )
)

(defun SD_start_timer ()
  (setq SD_start_time (getvar "DATE"))
  (setq SD_timer_active T)
  (SD_update_timer)
)

(defun SD_stop_timer ()
  (setq SD_timer_active nil)
)

(defun SD_update_timer ()
  (if SD_timer_active
    (progn
      (setq current_time (getvar "DATE"))
      (setq elapsed_seconds (* (- current_time SD_start_time) 86400.0))
      (setq SD_elapsed_time (fix elapsed_seconds))
      
      (setq minutes (fix (/ SD_elapsed_time 60)))
      (setq seconds (rem SD_elapsed_time 60))
      
      (setq time_str (strcat "Tempo: " 
                             (if (< minutes 10) "0" "") (itoa minutes) ":"
                             (if (< seconds 10) "0" "") (itoa seconds)))
      (set_tile "timer_display" time_str)
    )
  )
)

(defun SD_check_cell_value (key value_str / row_str col_str row col value valid)
  (if SD_game_active
    (progn
      (setq row_str (substr key 6 1))
      (setq col_str (substr key 8 1))
      (setq row (atoi row_str))
      (setq col (atoi col_str))
      
      (setq original_value (SD_get-cell SD_original row col))
      (if (or (null original_value) (= original_value 0))
        (progn
          (if (or (= value_str "") (= value_str "0"))
            (setq value 0)
            (setq value (atoi value_str))
          )
          
          (if (and (>= value 0) (<= value 9))
            (progn
              (setq valid (if (= value 0) T (SD_is_valid_move SD_puzzle row col value)))
              
              (if valid
                (progn
                  (setq SD_puzzle (SD_update_cell SD_puzzle row col value))
                  
                  (if (SD_is_board_complete SD_puzzle)
                    (progn
                      (SD_stop_timer)
                      (setq SD_game_active nil)
                      (set_tile "status" "PARABÉNS! Você completou o Sudoku corretamente!")
                      (alert "Parabéns! Você completou o Sudoku corretamente!")
                    )
                  )
                )
                (progn
                  (setq SD_mistakes (1+ SD_mistakes))
                  (set_tile "mistakes_display" (strcat "Erros: " (itoa SD_mistakes) "/" (itoa SD_max_mistakes)))
                  
                  (if (>= SD_mistakes SD_max_mistakes)
                    (progn
                      (SD_stop_timer)
                      (setq SD_game_active nil)
                      (set_tile "status" "FIM DE JOGO! Você excedeu o número máximo de erros.")
                      (alert "Fim de Jogo! Você excedeu o número máximo de erros.")
                    )
                    (alert "Movimento inválido! Verifique linha, coluna e bloco 3x3.")
                  )
                )
              )
            )
            (progn
              (set_tile key "")
              (alert "Digite apenas números de 1 a 9 (ou deixe vazio para apagar).")
            )
          )
        )
        (progn
          (set_tile key (itoa original_value))
          (alert "Esta célula é fixa e não pode ser alterada.")
        )
      )
    )
  )
)

(defun SD_provide_hint ()
  (if (and SD_game_active (> SD_hints_remaining 0))
    (progn
      (setq empty_cell (SD_find_empty_cell SD_puzzle))
      
      (if empty_cell
        (progn
          (setq row (car empty_cell))
          (setq col (cadr empty_cell))
          (setq solution_value (SD_get-cell SD_solution row col))
          (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
          
          (setq SD_puzzle (SD_update_cell SD_puzzle row col solution_value))
          (set_tile key (itoa solution_value))
          (mode_tile key 1)
          
          (setq SD_hints_remaining (1- SD_hints_remaining))
          (set_tile "hint_display" (strcat "Dicas: " (itoa SD_hints_remaining)))
          
          (if (SD_is_board_complete SD_puzzle)
            (progn
              (SD_stop_timer)
              (setq SD_game_active nil)
              (set_tile "status" "PARABÉNS! Você completou o Sudoku!")
              (alert "Parabéns! Você completou o Sudoku!")
            )
          )
        )
        (alert "Não há células vazias para dar dica!")
      )
    )
    (if (<= SD_hints_remaining 0)
      (alert "Você não tem mais dicas disponíveis!")
      (alert "Inicie um novo jogo primeiro!")
    )
  )
)

(defun SD_check_puzzle ()
  (if SD_game_active
    (progn
      (setq incorrect_cells 0)
      (setq row_list (SD_make_range 0 8))
      (setq col_list (SD_make_range 0 8))
      
      (foreach row row_list
        (foreach col col_list
          (setq puzzle_value (SD_get-cell SD_puzzle row col))
          (setq solution_value (SD_get-cell SD_solution row col))
          
          (if (and puzzle_value solution_value 
                   (/= puzzle_value 0) (/= puzzle_value solution_value))
            (setq incorrect_cells (1+ incorrect_cells))
          )
        )
      )
      
      (if (= incorrect_cells 0)
        (alert "Parabéns! Todas as células preenchidas estão corretas!")
        (alert (strcat "Existem " (itoa incorrect_cells) " células incorretas."))
      )
    )
    (alert "Inicie um novo jogo primeiro!")
  )
)

(defun SD_solve_puzzle ()
  ;; CORREÇÃO: Remove a confirmação que causava travamento
  (if SD_game_active
    (progn
      ;; Resolve imediatamente sem confirmação
      (SD_stop_timer)
      (setq SD_game_active nil)
      (setq SD_puzzle SD_solution)
      (SD_update_display)
      (set_tile "status" "Puzzle resolvido automaticamente.")
      (alert "Puzzle resolvido automaticamente!")
    )
    (alert "Inicie um novo jogo primeiro!")
  )
)

(defun SD_new_game ()
  (setq difficulty 
    (cond
      ((= (get_tile "easy") "1") "easy")
      ((= (get_tile "medium") "1") "medium")
      ((= (get_tile "hard") "1") "hard")
      ((= (get_tile "expert") "1") "expert")
      (T "medium")
    )
  )
  
  (setq SD_difficulty difficulty)
  (setq SD_hints_remaining 3)
  (setq SD_mistakes 0)
  (setq SD_game_active T)
  
  (SD_generate_puzzle)
  (SD_update_display)
  (SD_start_timer)
  
  (set_tile "status" "Novo jogo iniciado! Boa sorte!")
)

;; ======================================================================
;; FUNÇÃO PRINCIPAL
;; ======================================================================

(defun C:SUDOKU ()
  (setq SD_dcl_id (load_dialog "Sudoku.dcl"))
  (if (not (new_dialog "sudoku" SD_dcl_id))
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Sudoku!")
      (unload_dialog SD_dcl_id)
      (exit)
    )
  )
  
  (mode_tile "#arkz" 1)
  (SD_ShowSld "#img_logo" "ArkZLogo" -2)
  (SD_ShowSld "sep1"  "Separato" -2)
  (SD_ShowSld "sep2"  "Separato" -2)
  (SD_ShowSld "sep3"  "Separato" -2) 
  
  
  (set_tile "medium" "1")
  
  (action_tile "new_game" "(SD_new_game)")
  (action_tile "hint" "(SD_provide_hint)")
  (action_tile "check" "(SD_check_puzzle)")
  (action_tile "solve" "(SD_solve_puzzle)")  ;; CORRIGIDO: Sem confirmação
  (action_tile "sair" "(progn (SD_stop_timer) (done_dialog 0) (princ))")
  (action_tile "help" "(progn (Sudoku_Help) (princ))")
  
  (setq row 0)
  (while (< row 9)
    (setq col 0)
    (while (< col 9)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (action_tile key (strcat "(SD_check_cell_value \"" key "\" $value)"))
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  
  (setq SD_game_active nil)
  
  (setq empty_row '(0 0 0 0 0 0 0 0 0))
  (setq empty_board (list empty_row empty_row empty_row empty_row empty_row 
                          empty_row empty_row empty_row empty_row))
  
  (setq SD_solution empty_board)
  (setq SD_puzzle empty_board)
  (setq SD_original empty_board)
  
  (SD_update_display)
  
  (start_dialog)
  (unload_dialog SD_dcl_id)
  (princ)
)


;;;===========================================================================
;;; FUNÇÃO DE AJUDA
;;;===========================================================================
;;;---------------------------------------------------------------------------
;;; StringWrap - Lee Mac, 2011 (modificado)
(defun StringWrap (str len / pos)
  (if (< len (strlen str))
    (cons
      (substr str 1
        (cond
          ((setq pos (vl-string-position 32 (substr str 1 len) nil t)))
          ((setq pos (1- len)) len)
        )
      )
      (StringWrap (substr str (+ 2 pos)) len)
    )
    (list str)
  )
)

;;;---------------------------------------------------------------------------
;;; Lê linhas de um arquivo de texto - Chat-GPT, 2024
(defun read-lines (filepath / file lines line)
  (setq lines nil)
  (if (and (setq filepath (findfile filepath))
           (setq file (open filepath "r")))
    (progn
      (while (setq line (read-line file))
        (setq lines (append lines (list line)))
      )
      (close file)
    )
    (progn
      (alert (strcat "Arquivo não encontrado: " filepath))
      nil
    )
  )
  lines
)

;;;---------------------------------------------------------------------------
;;; Processa texto para exibição em list_box
(defun process-text-for-display (lines max-width)
  (if lines
    (apply 'append 
      (mapcar '(lambda (line) (StringWrap line max-width)) lines)
    )
    (list "Nenhuma informação disponível.")
  )
)

;;;---------------------------------------------------------------------------
;;; Função Sudoku_Help
(defun Sudoku_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Sudoku.txt
  (if (not (findfile "Sudoku.txt"))
    (progn
      (alert "O arquivo Sudoku.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Sudoku.dcl"))
               (new_dialog "Sudoku_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Sudoku.txt"))
            (progn
              (setq display-text (process-text-for-display lines 60))
              (start_list "lstAbout")
              (foreach line display-text
                (add_list line)
              )
              (end_list)
            )
            ;; Se não conseguir ler o arquivo (mesmo existindo)
            (progn
              (start_list "lstAbout")
              (foreach line '("Erro ao ler o arquivo de ajuda." 
                             "Verifique se o arquivo não está corrompido."
                             ""
                             "Contate o suporte técnico.")
                (add_list line)
              )
              (end_list)
            )
          )
          
          ;; Exibe logo
          (SD_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Sudoku - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Sudoku.dcl.")
      )
    )
  )
  (princ)
)
;;;

(princ "\nSudoku carregado. Digite Sudoku para iniciar o jogo.")
(princ)


(princ "\nSudoku carregado. Digite SUDOKU para iniciar.")
(princ)
