;; ====================================================================
;; MINESWEPPER_8X8.LSP - CORRIGIDO (V8 - Versão Final)
;; Correção: Força o fundo do tile da mina clicada para VERMELHO (Índice 1).
;; Manutenção da biblioteca de slides (Minesweeper.slb).
;; ====================================================================

;; Variáveis globais de estado
(setq MS_dcl_id nil)
(setq MS_board nil)
(setq MS_visibility_board nil)
(setq MS_game_over nil)
(setq MS_rows 8)
(setq MS_cols 8)
(setq MS_total_mines 10)
(setq MS_cells_remaining 0)
(setq MS_seed (getvar "DATE")) 

;; ====================================================================
;; FUNÇÕES AUXILIARES DE MANIPULAÇÃO DE LISTAS 
;; ====================================================================

(defun MS_make_range (start end / result)
  (setq result nil)
  (while (>= end start)
    (setq result (cons end result))
    (setq end (1- end))
  )
  result
)

(defun MS_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (MS_drop (1- n) (cdr lst)) nil))
)

(defun MS_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (MS_take (1- n) (cdr lst))))
)

(defun MS_update_cell (board row col value)
  (append 
    (MS_take row board) 
    (list 
      (append 
        (MS_take col (nth row board)) 
        (list value)                  
        (MS_drop (1+ col) (nth row board)) 
      )
    )
    (MS_drop (1+ row) board) 
  )
)

(defun MS_get-cell (board row col) 
  (if (and (>= row 0) (< row MS_rows) (>= col 0) (< col MS_cols))
      (nth col (nth row board))
      nil
  )
)

(defun MS_randnum (/ modulus multiplier increment)
  (setq modulus    65536
        multiplier 25173
        increment  13849)
  (setq MS_seed (rem (+ (* MS_seed multiplier) increment) modulus))
  (/ MS_seed modulus)
)

;; ====================================================================
;; FUNÇÕES DE EXIBIÇÃO GRÁFICA (USANDO SLB)
;; ====================================================================

(defun MS_ShowSld (tile slide color_index / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color_index) ; Define a cor de fundo
  
  ;; V7 CORREÇÃO: Referencia a biblioteca "Minesweeper.slb"
  (slide_image 0 0 x y (strcat "Minesweeper_8x8 (" slide ")")) 
  
  (end_image)
  (princ) 
)

(defun MS_update_board_display ()
  (setq MS_cells_remaining 0)
  (setq MS_rows_list (MS_make_range 0 (1- MS_rows)))
  (setq MS_cols_list (MS_make_range 0 (1- MS_cols)))
  
  (foreach row MS_rows_list
    (foreach col MS_cols_list
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq visibility (MS_get-cell MS_visibility_board row col))
      (setq content (MS_get-cell MS_board row col))
      
      (cond
        ((eq visibility 'R) ; Célula Revelada
         (cond
           ;; Nota: Em caso de derrota, o fundo é VERMELHO (1), e o slide MINE é exibido.
           ((eq content 'M) (MS_ShowSld key "MINE" 1)) ; <--- Cor 1 (VERMELHO) para a mina
           ((= content 0) (MS_ShowSld key "NUM_0" 255)) 
           (T (MS_ShowSld key (strcat "NUM_" (itoa content)) 255)) 
         )
         (action_tile key "") ; Desabilita o clique
        )
        (T ; Célula Escondida ('H')
         (MS_ShowSld key "HIDDEN" 253) ; Cor de fundo cinza para célula escondida
         (setq MS_cells_remaining (1+ MS_cells_remaining))
         
         (action_tile key (strcat "(progn (MS_cell_clicked \"" key "\") (princ))")) 
        )
      )
    )
  )
  
  (set_tile "mine_count_display" (strcat "Minas: " (itoa MS_total_mines)))
  (set_tile "cells_remaining_display" (strcat "Restantes: " (itoa (- MS_cells_remaining MS_total_mines))))
  (princ)
)

(defun MS_disable_cells ()
  (setq MS_rows_list (MS_make_range 0 (1- MS_rows)))
  (setq MS_cols_list (MS_make_range 0 (1- MS_cols)))
  
  (foreach row MS_rows_list
    (foreach col MS_cols_list
      (action_tile (strcat "cell_" (itoa row) "_" (itoa col)) "")
    )
  )
  (princ)
)

;; ====================================================================
;; FUNÇÕES DE LÓGICA DO JOGO (INALTERADAS)
;; ====================================================================

(defun MS_place_mines (/ row col mines_placed)
  (setq mines_placed 0)
  
  (while (< mines_placed MS_total_mines)
    (setq row (fix (* (MS_randnum) MS_rows)))
    (setq col (fix (* (MS_randnum) MS_cols)))
    
    (if (not (eq (MS_get-cell MS_board row col) 'M))
      (progn
        (setq MS_board (MS_update_cell MS_board row col 'M))
        (setq mines_placed (1+ mines_placed))
      )
    )
  )
  MS_board
)

(defun MS_calculate_adjacent_mines ()
  (setq MS_rows_list (MS_make_range 0 (1- MS_rows)))
  (setq MS_cols_list (MS_make_range 0 (1- MS_cols)))
  
  (foreach row MS_rows_list
    (foreach col MS_cols_list
      (if (not (eq (MS_get-cell MS_board row col) 'M))
        (progn
          (setq count 0)
          (foreach dr '(-1 0 1)
            (foreach dc '(-1 0 1)
              (if (or (= dr 0 dc 0) 
                      (not (MS_get-cell MS_board (+ row dr) (+ col dc)))) 
                  nil
                  (if (eq (MS_get-cell MS_board (+ row dr) (+ col dc)) 'M)
                      (setq count (1+ count))
                  )
              )
            )
          )
          (setq MS_board (MS_update_cell MS_board row col count))
        )
      )
    )
  )
  MS_board
)

(defun MS_reveal_cell (row col)
  (if (and (>= row 0) (< row MS_rows) (>= col 0) (< col MS_cols)) 
    (if (eq (MS_get-cell MS_visibility_board row col) 'H) 
      (progn
        (setq MS_visibility_board (MS_update_cell MS_visibility_board row col 'R))
        (setq content (MS_get-cell MS_board row col))
        
        (if (= content 0) 
          (foreach dr '(-1 0 1)
            (foreach dc '(-1 0 1)
              (if (not (and (= dr 0) (= dc 0)))
                (MS_reveal_cell (+ row dr) (+ col dc)) 
              )
            )
          )
        )
      )
    )
  )
  (princ)
)

(defun MS_check_win ()
  (setq revealed_count 0)
  (setq MS_rows_list (MS_make_range 0 (1- MS_rows)))
  (setq MS_cols_list (MS_make_range 0 (1- MS_cols)))
  
  (foreach row MS_rows_list
    (foreach col MS_cols_list
      (if (eq (MS_get-cell MS_visibility_board row col) 'R)
          (setq revealed_count (1+ revealed_count))
      )
    )
  )
  
  (if (= revealed_count (- (* MS_rows MS_cols) MS_total_mines))
    (progn
      (setq MS_game_over T)
      (set_tile "status" "PARABÉNS! VOCÊ VENCEU O CAMPO MINADO!")
      (MS_disable_cells)
      (alert "Você Venceu!")
      T
    )
    nil
  )
)

;; ====================================================================
;; FUNÇÕES DE CONTROLE PRINCIPAIS 
;; ====================================================================

(defun MS_update_slider_display (value_str)
  ;; Converte o valor do slider (string) para inteiro
  (setq new_mines (atoi value_str)) 
  
  ;; Atualiza a variável global de minas
  (setq MS_total_mines new_mines)
  
  ;; Atualiza o campo de texto para mostrar o novo valor
  (set_tile "slider_value_display" value_str)
  
  ;; Reinicia o jogo imediatamente para usar o novo número de minas
  (MS_initialize_game)
  (princ)
)

(defun C:MINESWEEPER_8X8 ()
  (setq MS_dcl_id (load_dialog "Minesweeper_8x8.dcl")) 
  (if (not (new_dialog "minesweeper_8x8" MS_dcl_id))
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Minesweeper!")
      (unload_dialog MS_dcl_id)
      (exit)
    )
  )
  ;; Comandos adicionais do usuário:
  (mode_tile "#arkz" 1)
  (MS_ShowSld "#img_logo" "ArkZLogo" -2)
  (MS_ShowSld "sep1"  "Separato" -2)
  (MS_ShowSld "sep2"  "Separato" -2)
  ;; Fim dos comandos adicionais
  
  ;; Inicializa o slider e o contador de minas <<<
  (set_tile "mine_slider" (itoa MS_total_mines)) 
  (set_tile "slider_value_display" (itoa MS_total_mines))
  
  (MS_initialize_game)
  (start_dialog)
  
  (unload_dialog MS_dcl_id) 
  (princ)
)

(defun MS_initialize_game ()
  (setq MS_game_over nil)
  
  (setq MS_rows_list (MS_make_range 0 (1- MS_rows)))
  (setq MS_cols_list (MS_make_range 0 (1- MS_cols)))
  
  (setq MS_board 
    (mapcar 
      '(lambda (r) (mapcar '(lambda (c) nil) MS_cols_list)) 
      MS_rows_list
    )
  )
  
  (setq MS_visibility_board 
    (mapcar 
      '(lambda (r) (mapcar '(lambda (c) 'H) MS_cols_list)) 
      MS_rows_list
    )
  )
  
  (MS_place_mines)
  (MS_calculate_adjacent_mines)
  
  (set_tile "status" "Jogo pronto. Clique em uma célula para começar!")
  
  (action_tile "reset" "(progn (MS_initialize_game) (princ))")
  (action_tile "sair" "(progn (done_dialog 0) (princ))")
  (action_tile "help" "(progn (Minesweeper_8x8_Help) (princ))")
  
  (MS_update_board_display)
  (princ) 
)

;; Processa clique na célula
(defun MS_cell_clicked (key / row_str col_str row col content)
  (if MS_game_over (princ)) 
  
  (setq row_str (substr key 6 1)) 
  (setq col_str (substr key 8 1))
  (setq row (atoi row_str))
  (setq col (atoi col_str))

  (setq content (MS_get-cell MS_board row col))
  
  (if (eq (MS_get-cell MS_visibility_board row col) 'R) 
      (princ) 
      
      (if (eq content 'M)
        (progn ; PERDEU
          (setq MS_game_over T)
          
          ;; 1. Altera a visibilidade da mina clicada
          (setq MS_visibility_board (MS_update_cell MS_visibility_board row col 'R)) 
          
          ;; 2. Desenha a mina explodida IMEDIATAMENTE (AGORA VERMELHO!)
          (MS_ShowSld key "MINE" 1) ; <--- CORRIGIDO PARA ÍNDICE 1 (VERMELHO)
          
          ;; 3. Desabilita o tabuleiro inteiro
          (MS_disable_cells)
          
          (set_tile "status" "GAME OVER! Você acertou uma mina.")
          (alert "FIM DE JOGO! Você acertou uma mina.")
          (princ) 
        )
        (progn ; REVELAÇÃO
          (MS_reveal_cell row col) 
          
          (MS_update_board_display) ; Atualiza o display (uma vez)
          
          (MS_check_win)
          (princ)
        )
      )
  )
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
;;; Função Minesweeper_8x8_Help
(defun Minesweeper_8x8_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Minesweeper_8x8.txt
  (if (not (findfile "Minesweeper_8x8.txt"))
    (progn
      (alert "O arquivo Minesweeper_8x8.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Minesweeper_8x8.dcl"))
               (new_dialog "Minesweeper_8x8_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Minesweeper_8x8.txt"))
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
          (MS_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Minesweeper_8x8 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
         
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Minesweeper_8x8.dcl.")
      )
    )
  )
  (princ)
)
;;;

(princ "\nMinesweeper_8x8 (Campo Minado Simplificado) carregado. Digite MINESWEEPER_8X8 para iniciar.")
(princ)
