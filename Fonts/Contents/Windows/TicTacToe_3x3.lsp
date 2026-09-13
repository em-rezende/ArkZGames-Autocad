;; ====================================================================
;; TIC-TAC-TOE 3X3 (Humano 'X' vs. Computador 'O') - CORRIGIDO
;; SOLUÇÃO ROBUSTA PARA ERRO: bad function: 1
;; ====================================================================

;; Variável global para o ID do diálogo
(setq T3_dcl_id nil)

;; Variáveis do jogo
(setq T3_board nil)
(setq T3_current_player 'X)

;; Funções Auxiliares: T3_drop, T3_take, T3_update_cell (inalteradas)
(defun T3_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (T3_drop (1- n) (cdr lst)) nil))
)
(defun T3_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (T3_take (1- n) (cdr lst))))
)
(defun T3_update_cell (T3_board row col value)
  (append (T3_take row T3_board) (list (append (T3_take col (nth row T3_board)) (list value) (T3_drop (1+ col) (nth row T3_board)))) (T3_drop (1+ row) T3_board))
)

;;; Função para exibir slides
(defun T3_ShowSld (tile slide color_index / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  
  ;; MODIFICAÇÃO: Usa o índice de cor passado (color_index)
  (fill_image 0 0 x y color_index) 
  
  (slide_image 0 0 x y
    (strcat "TicTacToe_3x3" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ) ; Garante retorno seguro
)

;; FUNÇÃO DE ATUALIZAÇÃO COM SLIDES (Todas as células com cor 254)
(defun T3_update_board_display ()
  (foreach row '(0 1 2)
    (foreach col '(0 1 2)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row T3_board)))
      
      ;; Define a cor fixa para todas as células (Ex: 254 - Cinza Claro)
      (setq color_index 253) 
      
      ;; Determina qual slide mostrar baseado no valor da célula
      (setq slide-name
        (cond
          ((eq val 'X) "X")     ; Slide para X
          ((eq val 'O) "O")     ; Slide para O
          (T "BLANK")           ; Slide para vazio
        )
      )
      
      ;; Chama a função T3_ShowSld com a cor fixa
      (T3_ShowSld key slide-name color_index)
      
      ;; Habilita ou desabilita o clique na célula
      (if (null val)
          ;; action_tile envolvido em (progn ... (princ)) para segurança
          (action_tile key (strcat "(progn (T3_cell_clicked \"" key "\") (princ))")) 
          (action_tile key "") 
      )
    )
  )
  (princ) ; Garante retorno seguro
)

(defun c:TicTacToe_3x3 ()
  (setq T3_dcl_id (load_dialog "TicTacToe_3x3.dcl")) 
  (if (not (new_dialog "tictactoe_3x3" T3_dcl_id))
    (progn
      (princ "\nErro ao carregar a caixa de diálogo!")
      (unload_dialog T3_dcl_id)
      (exit)
    )
  )
;;
  (mode_tile "#arkz" 1)
;;
  (T3_ShowSld "#img_logo" "ArkZLogo" -2)
  (T3_ShowSld "sep1"  "Separato" -2)
  (T3_ShowSld "sep2"  "Separato" -2)
;;
  (T3_initialize_game)
  (start_dialog)
  
  (unload_dialog T3_dcl_id) 
  (princ)
)

(defun T3_enable_cells ()
  (foreach key '("cell_0_0" "cell_0_1" "cell_0_2"
                 "cell_1_0" "cell_1_1" "cell_1_2"
                 "cell_2_0" "cell_2_1" "cell_2_2")
    ;; action_tile envolvido em (progn ... (princ)) para segurança
    (action_tile key (strcat "(progn (T3_cell_clicked \"" key "\") (princ))"))
  )
  (princ) ; Garante retorno seguro
)

(defun T3_initialize_game ()
  (setq T3_board '((nil nil nil) (nil nil nil) (nil nil nil)))
  (setq T3_current_player 'X) 
  (T3_update_board_display)
  (set_tile "status" "Sua vez de jogar.")
  
  ;; Configura ações dos botões - ENVOLVIDO EM (progn ... (princ)) PARA SEGURANÇA
  (action_tile "reset" "(progn (T3_reset_game) (princ))")
  (action_tile "sair" "(progn (done_dialog 0) (princ))")
  (action_tile "help" "(progn (TicTacToe_3x3_help) (princ))")
  
  (T3_enable_cells)
  (princ) ; Garante retorno seguro
)

;;; Função para reiniciar o jogo
(defun T3_reset_game ()
  (setq T3_board '((nil nil nil) (nil nil nil) (nil nil nil)))
  (setq T3_current_player 'X)
  (T3_update_board_display)
  (set_tile "status" "Sua vez de jogar.")
  (T3_enable_cells)
  (princ) ; Garante retorno seguro
)

(defun T3_cell_clicked (key / row_str col_str row col)
  (setq row_str (substr key 6 1))
  (setq col_str (substr key 8 1))
  (setq row (atoi row_str))
  (setq col (atoi col_str))

  (if (and (numberp row) (numberp col))
    (if (and (<= 0 row 2) (<= 0 col 2))
      (if (null (nth col (nth row T3_board)))
        (progn
          (setq T3_board (T3_update_cell T3_board row col T3_current_player))
          (T3_update_board_display) 
          
          (cond
            ((T3_check_win T3_board T3_current_player)
             (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
               (alert (strcat "Jogador " (if (eq T3_current_player 'X) "X" "O") " venceu!"))
               (set_tile "status" (strcat "Jogador " (if (eq T3_current_player 'X) "X" "O") " venceu!"))
               (T3_disable_cells)
               (princ) ; Garante retorno seguro
             )
            )
            ((T3_check_draw T3_board)
             (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
               (alert "Empate!")
               (set_tile "status" "Empate!")
               (T3_disable_cells)
               (princ) ; Garante retorno seguro
             )
            )
            (T
             (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
               (T3_switch_player)
               (if (eq T3_current_player 'O)
                 (T3_computer_move)
               )
               (princ) ; Garante retorno seguro
             )
            )
          )
        )
      )
    )
  )
  (princ) ; Retorno final seguro
)

(defun T3_switch_player ()
  (setq T3_current_player (if (eq T3_current_player 'X) 'O 'X))
  (set_tile "status" (strcat "Vez do Jogador " (if (eq T3_current_player 'X) "X" "O") "."))
  (princ) ; Garante retorno seguro
)

(defun T3_computer_move ()
  (setq move (T3_get-computer-move T3_board))
  (if move
    (progn
      (setq T3_board (T3_update_cell T3_board (car move) (cadr move) 'O))
      (T3_update_board_display)
      (if (T3_check_win T3_board 'O)
        (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
          (set_tile "status" "Computador venceu!")
          (T3_disable_cells)
          (princ) ; Garante retorno seguro
        )
        (if (T3_check_draw T3_board)
          (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
            (set_tile "status" "Empate!")
            (T3_disable_cells)
            (princ) ; Garante retorno seguro
          )
          (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
            (setq T3_current_player 'X)
            (set_tile "status" "Sua vez de jogar.")
            (princ) ; Garante retorno seguro
          )
        )
      )
    )
    (progn ; **ADICIONADO PROGN PARA RETORNO SEGURO**
      (set_tile "status" "Empate! (Sem movimentos)")
      (T3_disable_cells)
      (princ) ; Garante retorno seguro
    )
  )
  (princ) ; Retorno final seguro
)

(defun T3_get-computer-move (T3_board / move)
  (setq move nil) 
  (cond
    ((setq move (T3_find-winning-move T3_board 'O))) 
    ((setq move (T3_find-winning-move T3_board 'X)))
    ((null (nth 1 (nth 1 T3_board))) (setq move '(1 1)))
    ((setq move (T3_find-first-empty T3_board '((0 0) (0 2) (2 0) (2 2)))))
    ((setq move (T3_find-first-empty T3_board '((0 1) (1 0) (1 2) (2 1)))))
  )
  move
)

(defun T3_find-winning-move (T3_board player)
  (setq result nil)
  (foreach row '(0 1 2)
    (foreach col '(0 1 2)
      (if (null (nth col (nth row T3_board)))
        (progn
          (setq temp (T3_update_cell T3_board row col player))
          (if (and (not result) (T3_check_win temp player))
            (setq result (list row col))
          )
        )
      )
    )
  )
  result
)

(defun T3_find-first-empty (T3_board cells)
  (setq result nil)
  (foreach cell cells
    (if (and (not result) (null (nth (cadr cell) (nth (car cell) T3_board))))
      (setq result cell)
    )
  )
  result
)

(defun T3_check_win (T3_board player)
  (or
    (and (eq (nth 0 (nth 0 T3_board)) player) (eq (nth 1 (nth 0 T3_board)) player) (eq (nth 2 (nth 0 T3_board)) player))
    (and (eq (nth 0 (nth 1 T3_board)) player) (eq (nth 1 (nth 1 T3_board)) player) (eq (nth 2 (nth 1 T3_board)) player))
    (and (eq (nth 0 (nth 2 T3_board)) player) (eq (nth 1 (nth 2 T3_board)) player) (eq (nth 2 (nth 2 T3_board)) player))
    (and (eq (nth 0 (nth 0 T3_board)) player) (eq (nth 0 (nth 1 T3_board)) player) (eq (nth 0 (nth 2 T3_board)) player))
    (and (eq (nth 1 (nth 0 T3_board)) player) (eq (nth 1 (nth 1 T3_board)) player) (eq (nth 1 (nth 2 T3_board)) player))
    (and (eq (nth 2 (nth 0 T3_board)) player) (eq (nth 2 (nth 1 T3_board)) player) (eq (nth 2 (nth 2 T3_board)) player))
    (and (eq (nth 0 (nth 0 T3_board)) player) (eq (nth 1 (nth 1 T3_board)) player) (eq (nth 2 (nth 2 T3_board)) player))
    (and (eq (nth 2 (nth 0 T3_board)) player) (eq (nth 1 (nth 1 T3_board)) player) (eq (nth 0 (nth 2 T3_board)) player))
  )
)

(defun T3_check_draw (T3_board)
  (not (member nil (apply 'append T3_board)))
)

(defun T3_disable_cells ()
  (foreach key '("cell_0_0" "cell_0_1" "cell_0_2"
                 "cell_1_0" "cell_1_1" "cell_1_2"
                 "cell_2_0" "cell_2_1" "cell_2_2")
    (action_tile key "")
  )
  (princ) ; Garante retorno seguro
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
;;; Função TicTacToe_3x3_Help
(defun TicTacToe_3x3_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo TicTacToe_3x3.txt
  (if (not (findfile "TicTacToe_3x3.txt"))
    (progn
      (alert "O arquivo TicTacToe_3x3.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "TicTacToe_3x3.dcl"))
               (new_dialog "TicTacToe_3x3_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "TicTacToe_3x3.txt"))
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
          (T3_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "TicTacToe_3x3 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo TicTacToe_3x3.dcl.")
      )
    )
  )
  (princ)
)
;;;


(princ "\nTicTacToe_3x3 carregado. Digite TicTacToe_3x3 para iniciar o jogo.")
(princ)
