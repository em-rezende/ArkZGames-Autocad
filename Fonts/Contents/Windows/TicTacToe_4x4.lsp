;; ====================================================================
;; TIC-TAC-TOE 4X4 (Humano 'X' vs. Computador 'O') - CORRIGIDO
;; SOLUÇÃO ROBUSTA PARA ERRO: bad function: 1
;; ====================================================================

;; Variável global para o ID do diálogo
(setq T4_dcl_id nil)

;; Variáveis do jogo
(setq T4_board_size 4)  ; Tamanho do tabuleiro 4x4
(setq T4_win_count 3)   ; Valor inicial, correspondente à seleção padrão no DCL
(setq T4_board nil)
(setq T4_current_player 'X)

;; Função chamada pelos botões de rádio para definir a regra de vitória
(defun T4_set_win_count (key_name / count state)
    (setq state (get_tile key_name)) 
    
    (if (= state "1")
        (progn
            (if (eq key_name "win_3")
                (setq count 3)
                (setq count 4)
            )
            (setq T4_win_count count)
            (princ (strcat "\nRegra de Vitoria definida para: " (itoa T4_win_count) " em Linha."))
        )
    )
    (princ) ; Garante retorno seguro
)

;; Funções Auxiliares: T4_drop, T4_take, T4_update_cell
(defun T4_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (T4_drop (1- n) (cdr lst)) nil))
)

(defun T4_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (T4_take (1- n) (cdr lst))))
)

(defun T4_update_cell (T4_board row col value / new_row)
  
  (setq new_row 
    (append (T4_take col (nth row T4_board)) 
            (list value) 
            (T4_drop (1+ col) (nth row T4_board)))
  )
  
  (append (T4_take row T4_board) 
          (list new_row) 
          (T4_drop (1+ row) T4_board))
)

;;; Função para exibir slides
(defun T4_ShowSld (tile slide color_index / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color_index) 
  (slide_image 0 0 x y
    (strcat "TicTacToe_4x4" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ) ; Garante retorno seguro
)

;; FUNÇÃO DE ATUALIZAÇÃO COM SLIDES
(defun T4_update_board_display ()
  (foreach row '(0 1 2 3)
    (foreach col '(0 1 2 3)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row T4_board)))
      
      (setq color_index 253) 
	  
      (setq slide-name
        (cond
          ((eq val 'X) "X")     
          ((eq val 'O) "O")     
          (T "BLANK")           
        )
      )
   
      (T4_ShowSld key slide-name color_index)
      
      (if (null val)
          ;; action_tile envolvido em (progn ... (princ)) para segurança, embora T4_cell_clicked já garanta o retorno
          (action_tile key (strcat "(progn (T4_cell_clicked \"" key "\") (princ))")) 
          (action_tile key "") 
      )
    )
  )
  (princ)
)

;; Função principal
(defun C:TICTACTOE_4X4 ()
  (setq T4_dcl_id (load_dialog "tictactoe_4x4.dcl"))
  
  (if (not (new_dialog "tictactoe_4x4" T4_dcl_id))
    (exit)
  )

  (mode_tile "#arkz" 1)

  (T4_ShowSld "#img_logo" "ArkZLogo" -2)
  (T4_ShowSld "sep1"  "Separato" -2)
  (T4_ShowSld "sep2"  "Separato" -2)
  
  (setq T4_win_count 3)
  (set_tile "win_3" "1")
  
  ;; Protegendo as chamadas de action_tile com (progn (princ))
  (action_tile "win_3" "(progn (T4_set_win_count \"win_3\") (princ))")
  (action_tile "win_4" "(progn (T4_set_win_count \"win_4\") (princ))")
  
  (T4_initialize_game)
  
  (action_tile "cancel" "(progn (done_dialog) (princ))")
  
  (start_dialog)
  (unload_dialog T4_dcl_id)
  (princ)
)

;; Habilita todas as células 4x4
(defun T4_enable_cells ()
  (foreach row '(0 1 2 3)
    (foreach col '(0 1 2 3)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (action_tile key (strcat "(progn (T4_cell_clicked \"" key "\") (princ))"))
    )
  )
  (princ) ; Garante retorno seguro
)

;; Inicializa o jogo 4x4
(defun T4_initialize_game ()
  (setq T4_board '((nil nil nil nil) 
                (nil nil nil nil) 
                (nil nil nil nil) 
                (nil nil nil nil)))
  (setq T4_current_player 'X) 
  (T4_update_board_display)
  (set_tile "status" "Sua vez de jogar. (X = Jogador, O = Computador)")
  
  ;; Protegendo as chamadas de action_tile com (progn (princ))
  (action_tile "reset" "(progn (T4_reset_game) (princ))")
  (action_tile "sair" "(progn (done_dialog 0) (princ))")
  (action_tile "help" "(progn (TicTacToe_4x4_help) (princ))")
  
  (T4_enable_cells)
  (princ) ; Garante retorno seguro
)

;; Função para reiniciar o jogo 4x4
(defun T4_reset_game ()
  (setq T4_board '((nil nil nil nil) 
                (nil nil nil nil) 
                (nil nil nil nil) 
                (nil nil nil nil)))
  (setq T4_current_player 'X)
  (T4_update_board_display)
  (set_tile "status" "Sua vez de jogar. (X = Jogador, O = Computador)")
  (T4_enable_cells)
  (princ) ; Garante retorno seguro
)

;; Processa clique na célula
(defun T4_cell_clicked (key / row_str col_str row col)
  (setq row_str (substr key 6 1))
  (setq col_str (substr key 8 1))
  (setq row (atoi row_str))
  (setq col (atoi col_str))

  (if (and (numberp row) (numberp col))
    (if (and (<= 0 row 3) (<= 0 col 3))
      (if (null (nth col (nth row T4_board)))
        (progn
          (setq T4_board (T4_update_cell T4_board row col T4_current_player))
          (T4_update_board_display) 
          
          (cond
            ((T4_check_win T4_board T4_current_player)
             (alert (strcat "Jogador " (if (eq T4_current_player 'X) "X" "O") " venceu!"))
             (set_tile "status" (strcat "Jogador " (if (eq T4_current_player 'X) "X" "O") " venceu!"))
             (T4_disable_cells)
             (princ) ; **GARANTIA DE RETORNO SEGURO**
            )
            ((T4_check_draw T4_board)
             (alert "Empate!")
             (set_tile "status" "Empate!")
             (T4_disable_cells)
             (princ) ; **GARANTIA DE RETORNO SEGURO**
            )
            (T
             (T4_switch_player)
             (if (eq T4_current_player 'O)
               (T4_computer_move)
             )
             (princ) ; **GARANTIA DE RETORNO SEGURO**
            )
          )
        )
      )
    )
  )
  (princ) ; Retorno final seguro
)

(defun T4_switch_player ()
  (setq T4_current_player (if (eq T4_current_player 'X) 'O 'X))
  (set_tile "status" (strcat "Vez do Jogador " (if (eq T4_current_player 'X) "X" "O") "."))
  (princ) ; Garante retorno seguro
)

;; IA do computador para 4x4
(defun T4_computer_move ()
  (setq move (T4_get_computer_move T4_board))
  (if move
    (progn
      (setq T4_board (T4_update_cell T4_board (car move) (cadr move) 'O))
      (T4_update_board_display)
      (if (T4_check_win T4_board 'O)
        (progn
          (set_tile "status" "Computador venceu!")
          (T4_disable_cells)
          (princ) ; **GARANTIA DE RETORNO SEGURO**
        )
        (if (T4_check_draw T4_board)
          (progn
            (set_tile "status" "Empate!")
            (T4_disable_cells)
            (princ) ; **GARANTIA DE RETORNO SEGURO**
          )
          (progn
            (setq T4_current_player 'X)
            (set_tile "status" "Sua vez de jogar.")
            (princ) ; **GARANTIA DE RETORNO SEGURO**
          )
        )
      )
    )
    (progn
      (set_tile "status" "Empate! (Sem movimentos)")
      (T4_disable_cells)
      (princ) ; **GARANTIA DE RETORNO SEGURO**
    )
  )
  (princ) ; Retorno final seguro
)

;; Estratégia do computador para 4x4
(defun T4_get_computer_move (T4_board / move)
  (setq move nil) 
  (cond
    ((setq move (T4_find_winning_move T4_board 'O))) 
    ((setq move (T4_find_winning_move T4_board 'X)))
    ((null (nth 1 (nth 1 T4_board))) (setq move '(1 1)))
    ((null (nth 2 (nth 2 T4_board))) (setq move '(2 2)))
    ((setq move (T4_find_first_empty T4_board '((0 0) (0 3) (3 0) (3 3)))))
    ((setq move (T4_find_first_empty T4_board '((0 1) (0 2) (1 0) (1 3) (2 0) (2 3) (3 1) (3 2)))))
    ((setq move (T4_find_first_empty T4_board '((1 1) (1 2) (2 1) (2 2)))))
  )
  move
)

;; Encontra jogada vencedora para 4x4
(defun T4_find_winning_move (T4_board player)
  (setq result nil)
  (foreach row '(0 1 2 3)
    (foreach col '(0 1 2 3)
      (if (null (nth col (nth row T4_board)))
        (progn
          (setq temp (T4_update_cell T4_board row col player))
          (if (and (not result) (T4_check_win temp player))
            (setq result (list row col))
          )
          (setq temp nil) ; Limpa temp, segurança
        )
      )
    )
  )
  result
)

;; Encontra primeira célula vazia
(defun T4_find_first_empty (T4_board cells)
  (setq result nil)
  (foreach cell cells
    (if (and (not result) (null (nth (cadr cell) (nth (car cell) T4_board))))
      (setq result cell)
    )
  )
  result
)

;; Função auxiliar para verificar sequências de N em linha
(defun T4_check_line_win (T4_board player start_row start_col delta_row delta_col / row col count result)
  (setq count 0)
  (setq result nil) 
  (setq row start_row)
  (setq col start_col)
  
  (while (and (not result) (>= row 0) (< row 4) (>= col 0) (< col 4)) 
    
    (if (eq (nth col (nth row T4_board)) player)
      (setq count (1+ count))
      (setq count 0)
    )
    
    (if (= count T4_win_count)
      (setq result T)
    )
    
    (setq row (+ row delta_row))
    (setq col (+ col delta_col))
  )
  result
)

;; Verifica vitória para 4x4 (T4_win_count em linha)
(defun T4_check_win (T4_board player)
  (or
    ;; Linhas horizontais
    (T4_check_line_win T4_board player 0 0 0 1)
    (T4_check_line_win T4_board player 1 0 0 1)
    (T4_check_line_win T4_board player 2 0 0 1)
    (T4_check_line_win T4_board player 3 0 0 1)
    
    ;; Colunas verticais
    (T4_check_line_win T4_board player 0 0 1 0)
    (T4_check_line_win T4_board player 0 1 1 0)
    (T4_check_line_win T4_board player 0 2 1 0)
    (T4_check_line_win T4_board player 0 3 1 0)
    
    ;; Diagonais
    (T4_check_line_win T4_board player 0 0 1 1)
    (T4_check_line_win T4_board player 0 3 1 -1) 
    
    ;; Diagonais Secundárias (para 3 em linha em 4x4)
    (T4_check_line_win T4_board player 1 0 1 1)
    (T4_check_line_win T4_board player 0 1 1 1)
    (T4_check_line_win T4_board player 0 2 1 -1)
    (T4_check_line_win T4_board player 1 3 1 -1)
  )
)

;; Verifica empate para 4x4
(defun T4_check_draw (T4_board)
  (not (member nil (apply 'append T4_board)))
)

;; Desabilita todas as células 4x4
(defun T4_disable_cells ()
  (foreach row '(0 1 2 3)
    (foreach col '(0 1 2 3)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (action_tile key "")
    )
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
;;; Função TicTacToe_4x4_Help
(defun TicTacToe_4x4_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo TicTacToe_4x4.txt
  (if (not (findfile "TicTacToe_4x4.txt"))
    (progn
      (alert "O arquivo TicTacToe_4x4.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "TicTacToe_4x4.dcl"))
               (new_dialog "TicTacToe_4x4_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "TicTacToe_4x4.txt"))
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
          (T4_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "TicTacToe_4x4 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo TicTacToe_4x4.dcl.")
      )
    )
  )
  (princ)
)
;;;
(princ "\nTicTacToe_4x4 carregado. Digite TicTacToe_4x4 para iniciar o jogo.")
(princ)