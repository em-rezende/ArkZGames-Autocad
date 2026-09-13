;; ============================================
;; TORRE DE HANÓI - Jogo Interativo para AutoCAD
;; Versão: 2.0
;; Autor: [Seu Nome]
;; Data: [Data]
;; Descrição: Implementação do clássico jogo Torre de Hanói
;;            com interface DCL e controle por clique
;; ============================================

(vl-load-com)

;; ============================================
;; VARIÁVEIS GLOBAIS
;; ============================================

;; Estado do jogo
(setq *hastes* (list nil nil nil))      ;; Lista com os discos em cada haste (A, B, C)
(setq *num_discos* 0)                   ;; Número total de discos no jogo
(setq *movimentos* 0)                   ;; Contador de movimentos realizados
(setq *historico* nil)                  ;; Histórico de movimentos

;; Controle de seleção
(setq *origem_selecionada* nil)         ;; Índice da haste de origem selecionada
(setq *destino_selecionado* nil)        ;; Índice da haste de destino selecionada


;; Novas variáveis globais para escala/dpi
(setq *hanoi_scale_factor* 1.0)  ; Fator de escala inicial

;; ============================================
;; FUNÇÕES PRINCIPAIS
;; ============================================

;; --------------------------------------------------
;; Função: C:HANOI
;; Descrição: Função principal que inicia o jogo
;; Chamada: Digite HANOI no AutoCAD
;; --------------------------------------------------
(defun c:hanoi ()
  (princ "\n=== TORRE DE HANÓI ===")
  
  ;; Carrega o diálogo DCL
  (setq dcl_id (load_dialog "hanoi.dcl"))
  
  ;; Verifica se o diálogo foi carregado corretamente
  (if (not (new_dialog "hanoi_dialog" dcl_id))
    (progn
      (alert "Erro ao carregar o diálogo!")
      (unload_dialog dcl_id)
      (princ)
      (exit)
    )
  )
  
  ;; Inicializa o jogo com configurações padrão
  (inicializar_jogo)
  
  ;; Configura ações dos controles
  (action_tile "img_a" "(selecionar_haste 0 $key)")
  (action_tile "img_b" "(selecionar_haste 1 $key)")
  (action_tile "img_c" "(selecionar_haste 2 $key)")
  (action_tile "slider_discos" "(atualizar_valor_slider $value)")
  (action_tile "btn_reset" "(resetar_jogo)")
  (action_tile "help" "(Hanoi_Help)")
  (action_tile "accept" "(done_dialog)")
  
  ;; Inicia o diálogo
  (start_dialog)
  (unload_dialog dcl_id)
  (princ)
)

;;; ============================================
;; FUNÇÕES DE CONTROLE DE JOGO
;; ============================================

;; --------------------------------------------------
;; Função: SELECIONAR_HASTE
;; Parâmetros: idx - índice da haste (0=A, 1=B, 2=C)
;;             key - nome do tile da imagem
;; Descrição: Gerencia a seleção de hastes para movimentos
;; --------------------------------------------------
(defun selecionar_haste (idx key)
  (cond
    ;; Verifica se jogo foi iniciado
    ((= *num_discos* 0)
     (set_tile "txt_status" "Inicie um jogo primeiro! Use o slider."))
    
    ;; Verifica se jogo foi resetado
    ((and (null (nth 0 *hastes*))
          (null (nth 1 *hastes*))
          (null (nth 2 *hastes*)))
     (set_tile "txt_status" "Jogo resetado. Use o slider para reiniciar."))
    
    ;; Lógica principal de seleção
    (t
     (if (not *origem_selecionada*)
       ;; Primeiro clique: seleciona origem
       (progn
         (limpar_erro_selecao key)
         (setq *origem_selecionada* idx)
         (set_tile "txt_status" (strcat "Selecionada haste " (nome_haste idx) " como origem"))
         (destacar_haste key t)
       )
       
       ;; Segundo clique: seleciona destino e move
       (progn
         (setq *destino_selecionado* idx)
         
         (if (= *origem_selecionada* *destino_selecionado*)
           ;; Selecionou mesma haste
           (progn
             (set_tile "txt_status" "Origem e destino devem ser diferentes!")
             (limpar_selecoes)
           )
           
           ;; Selecionou haste diferente - executa movimento
           (executar_movimento *origem_selecionada* *destino_selecionado*)
         )
       )
     )
    )
  )
)

;; --------------------------------------------------
;; Função: EXECUTAR_MOVIMENTO
;; Parâmetros: origem - índice da haste de origem
;;             destino - índice da haste de destino
;; Descrição: Executa um movimento se válido
;; --------------------------------------------------
(defun executar_movimento (origem destino / haste_o haste_d disco)
  (setq haste_o (nth origem *hastes*))
  (setq haste_d (nth destino *hastes*))
  
  (cond
    ;; Caso 1: Haste de origem vazia
    ((null haste_o)
     (set_tile "txt_status" (strcat "Haste " (nome_haste origem) " está vazia"))
     (mostrar_erro_movimento (cond ((= origem 0) "img_a") ((= origem 1) "img_b") (t "img_c"))))
    
    ;; Caso 2: Movimento inválido (disco maior sobre menor)
    ((and haste_d (< (car haste_o) (car haste_d)))
     (set_tile "txt_status" "Não pode colocar disco maior sobre menor")
     (mostrar_erro_movimento (cond ((= destino 0) "img_a") ((= destino 1) "img_b") (t "img_c"))))
    
    ;; Caso 3: Movimento válido
    (t
     (setq disco (car haste_o))
     
     ;; Atualiza estado das hastes
     (setq *hastes* (atualizar_haste *hastes* origem (cdr haste_o)))
     (setq *hastes* (atualizar_haste *hastes* destino (cons disco haste_d)))
     
     ;; Atualiza histórico e contador
     (setq *historico* (cons (list origem destino disco) *historico*))
     (setq *movimentos* (1+ *movimentos*))
     
     ;; Redesenha interface
     (desenhar_todas_hastes)
     
     ;; Atualiza textos
     (set_tile "txt_movimentos" (strcat "Movimentos: " (itoa *movimentos*)))
     (set_tile "txt_status" (strcat "Movido disco " (itoa disco)
                                   " de " (nome_haste origem)
                                   " para " (nome_haste destino)))
     
     ;; Atualiza contadores de discos
     (set_tile "txt_a" (strcat "Torre A: " (itoa (length (nth 0 *hastes*)))))
     (set_tile "txt_b" (strcat "Torre B: " (itoa (length (nth 1 *hastes*)))))
     (set_tile "txt_c" (strcat "Torre C: " (itoa (length (nth 2 *hastes*)))))
     
     ;; Verifica se jogador venceu
     (verificar_vitoria)
     
     ;; Limpa seleções para próximo movimento
     (limpar_selecoes)
    )
  )
)

;; --------------------------------------------------
;; Função: INICIAR_JOGO_COM_DISCOS
;; Parâmetros: n - número de discos (3-8)
;; Descrição: Inicia novo jogo com n discos
;; --------------------------------------------------
(defun iniciar_jogo_com_discos (n)
  (if (or (< n 3) (> n 8))
    (set_tile "txt_status" "Número de discos deve ser entre 3 e 8")
    (progn
      ;; Inicializa variáveis
      (setq *num_discos* n)
      (setq *movimentos* 0)
      (setq *historico* nil)
      (limpar_selecoes)
      
      ;; Cria lista de discos (1 = menor, n = maior)
      (setq discos nil)
      (setq i n)
      (repeat n
        (setq discos (cons i discos))
        (setq i (1- i))
      )
      (setq discos (reverse discos))
      
      ;; Configura hastes iniciais
      (setq *hastes* (list discos nil nil))
      
      ;; Desenha jogo inicial
      (desenhar_todas_hastes)
      
      ;; Atualiza interface
      (set_tile "txt_status" (strcat "Jogo iniciado com " (itoa n) " discos"))
      (set_tile "txt_movimentos" "Movimentos: 0")
      (set_tile "txt_minimo" (strcat "Mínimo: " (itoa (- (expt 2 n) 1))))
      (set_tile "txt_a" (strcat "Torre A: " (itoa n)))
      (set_tile "txt_b" "Torre B: 0")
      (set_tile "txt_c" "Torre C: 0")
      
      (princ (strcat "\nJogo iniciado: " (itoa n) " discos"))
    )
  )
)

;; ============================================
;; FUNÇÕES DE INTERFACE GRÁFICA
;; ============================================

;; --------------------------------------------------
;; HN_ShowSld - Exibe slides em tiles DCL
;; --------------------------------------------------
;; (HN_ShowSld "tile" "library" "slide" color)
;; Parâmetros:
;;   tile    - Nome do controle de imagem no DCL
;;   library - Nome da biblioteca de slides
;;   slide   - Nome do slide (com ou sem extensão)
;;   color   - Cor de fundo (inteiro AutoCAD)
;; Uso:
;;   (HN_ShowSld "img1" "Lib" "logo" -2)
;;   (HN_ShowSld "thumb" "Proj" "preview.sld" 0)
;; --------------------------------------------------
(defun HN_ShowSld (tile library slide color / x y)
  (and
    (setq x (dimx_tile tile))
    (setq y (dimy_tile tile))
    (start_image tile)
    (fill_image 0 0 x y color)
    (slide_image 0 0 x y 
      (strcat library 
              " (" 
              (vl-filename-base slide) 
              ")"
      )
    )
    (end_image)
  )
  (princ)
)

;; ============================================
;; FUNÇÕES DE ESCALONAMENTO ADAPTATIVO
;; ============================================
(defun calcular_fator_escala (img_key / x y base_size)
  ;; Calcula fator de escala baseado no tamanho real do tile
  ;; Similar à lógica do Border.lsp
  (setq x (dimx_tile img_key))
  (setq y (dimy_tile img_key))
  
  ;; Tamanho base de referência (para telas 1920x1080)
  (setq base_size 200)
  
  ;; Calcula fator baseado na menor dimensão
  (setq *hanoi_scale_factor* (/ (min x y) base_size))
  
  ;; Limites mínimos e máximos
  (if (< *hanoi_scale_factor* 0.5)
    (setq *hanoi_scale_factor* 0.5)
  )
  (if (> *hanoi_scale_factor* 2.0)
    (setq *hanoi_scale_factor* 2.0)
  )
  *hanoi_scale_factor*
)

(defun escala (valor)
  ;; Aplica fator de escala a um valor
  (* valor *hanoi_scale_factor*)
)

(defun escala_inversa (valor)
  ;; Aplica fator de escala inverso (para garantir proporção)
  (/ valor *hanoi_scale_factor*)
)

;; --------------------------------------------------
;; Função: DESENHAR_HASTE_COM_DISCOS
;; Parâmetros: img_key - nome do tile da imagem
;;             discos - lista de discos na haste
;;             haste_nome - nome da haste (A, B ou C)
;; Descrição: Desenha uma haste com seus discos
;; --------------------------------------------------
(defun desenhar_haste_com_discos (img_key discos haste_nome / x y centro_x y_pos largura base_width max_width min_width)
  ;; Desenha haste com discos - VERSÃO ADAPTATIVA
  (setq x (dimx_tile img_key))
  (setq y (dimy_tile img_key))
  (setq centro_x (/ x 2))
  
  ;; Calcula fator de escala para este tile específico
  (calcular_fator_escala img_key)
  
  (start_image img_key)
  (fill_image 0 0 x y 0)  ; Fundo preto
  
  ;; 1. Desenha HASTE (largura proporcional)
  (setq haste_width (fix (escala 4)))  ; Base 4 pixels, escala proporcional
  (fill_image 
    (- centro_x (/ haste_width 2)) 
    (fix (escala 20)) 
    haste_width 
    (- y (fix (escala 40))) 
    7
  )
  
  ;; 2. Desenha BASE (largura proporcional)
  (setq base_width (fix (escala 120)))
  (fill_image 
    (- centro_x (/ base_width 2)) 
    (- y (fix (escala 20))) 
    base_width 
    (fix (escala 4)) 
    7
  )
  
  ;; 3. Desenha DISCOS (se houver)
  (if discos
    (progn
      (setq y_pos (- y (fix (escala 52))))  ; Posição Y inicial (acima da base)
      
      ;; Define limites para largura dos discos (proporcionais ao tile)
      (setq max_width (* x 0.8))  ; 80% da largura do tile
      (setq min_width (fix (escala 10)))  ; Mínimo 10 pixels escalados
      
      ;; Desenha discos do MAIOR (base) para o MENOR (topo)
      (foreach disco (reverse discos)
        ;; Largura escalada e proporcional ao disco
        ;; Fórmula: largura_base - (disco-1) * decremento
        (setq largura_base (fix (* x 0.7)))  ; 70% da largura do tile
        (setq decremento (fix (/ largura_base (* *num_discos* 1)))) ; (* *num_discos* 1) fixa o tamanho do último disco
        
        (setq largura (- largura_base (* (- disco 1) decremento)))
        
        ;; Aplica limites
        (if (> largura max_width)
          (setq largura max_width)
        )
        (if (< largura min_width)
          (setq largura min_width)
        )
        
        ;; Altura do disco (proporcional)
        (setq altura_disco (fix (escala 18)))
        
        ;; Desenha DISCO
        (fill_image 
          (- centro_x (/ largura 2))
          y_pos
          largura
          altura_disco
          disco
        )
        
        ;; BORDA do disco (2 pixels escalados)
        (fill_image 
          (- centro_x (/ largura 2))
          y_pos
          largura
          (fix (escala 2))
          0
        )
        
        ;; Espaço entre discos (proporcional)
        (setq y_pos (- y_pos (fix (escala 27))))
      )
    )
  )
  
  (end_image)
  
  ;; Atualiza texto
  (set_tile (strcat "txt_" (strcase (substr haste_nome 1 1)))
            (strcat haste_nome ": " (itoa (length discos))))
)
;; --------------------------------------------------
;; Função: DESTACAR_HASTE
;; Parâmetros: img_key - nome do tile
;;             destacar - T para destacar, nil para normal
;; Descrição: Destaca haste com borda amarela (seleção)
;; --------------------------------------------------
(defun destacar_haste (img_key destacar / x y centro_x rect_x1 rect_y1 rect_x2 rect_y2 border_thickness)
  ;; Destaca ou remove destaque de uma haste - POSICIONAMENTO CORRIGIDO
  (setq x (dimx_tile img_key))
  (setq y (dimy_tile img_key))
  (setq centro_x (/ x 2))
  
  ;; ESPESSURA da borda (fixa, não escala muito)
  (setq border_thickness 1)
  
  ;; COORDENADAS do retângulo de destaque (cobre toda a área visível da haste)
  ;; Margens para não encostar nas bordas do tile
  (setq margin_h (fix (/ x 25)))  ; 10% de margem horizontal
  (setq margin_v (fix (/ y 25)))  ; 10% de margem vertical
  
  (setq rect_x1 (+ margin_h border_thickness))
  (setq rect_y1 (+ margin_v border_thickness))
  (setq rect_x2 (- x margin_h border_thickness))
  (setq rect_y2 (- y margin_v border_thickness))
  
  (start_image img_key)
  
  (if destacar
    ;; Desenha borda amarela (seleção)
    (progn
      ;; Linha SUPERIOR
      (fill_image 
        rect_x1
        rect_y1
        (- rect_x2 rect_x1)
        border_thickness
        2  ; Amarelo
      )
      
      ;; Linha INFERIOR
      (fill_image 
        rect_x1
        (- rect_y2 border_thickness)
        (- rect_x2 rect_x1)
        border_thickness
        2  ; Amarelo
      )
      
      ;; Linha ESQUERDA
      (fill_image 
        rect_x1
        rect_y1
        border_thickness
        (- rect_y2 rect_y1)
        2  ; Amarelo
      )
      
      ;; Linha DIREITA
      (fill_image 
        (- rect_x2 border_thickness)
        rect_y1
        border_thickness
        (- rect_y2 rect_y1)
        2  ; Amarelo
      )
    )
    
    ;; Remove destaque (desenha preto nas mesmas coordenadas)
    (progn
      ;; Linha SUPERIOR
      (fill_image 
        rect_x1
        rect_y1
        (- rect_x2 rect_x1)
        border_thickness
        0  ; Preto
      )
      
      ;; Linha INFERIOR
      (fill_image 
        rect_x1
        (- rect_y2 border_thickness)
        (- rect_x2 rect_x1)
        border_thickness
        0  ; Preto
      )
      
      ;; Linha ESQUERDA
      (fill_image 
        rect_x1
        rect_y1
        border_thickness
        (- rect_y2 rect_y1)
        0  ; Preto
      )
      
      ;; Linha DIREITA
      (fill_image 
        (- rect_x2 border_thickness)
        rect_y1
        border_thickness
        (- rect_y2 rect_y1)
        0  ; Preto
      )
    )
  )
  
  (end_image)
)
;; --------------------------------------------------
;; Função: MOSTRAR_ERRO_MOVIMENTO
;; Parâmetros: img_key - nome do tile
;; Descrição: Destaca haste com borda vermelha (erro)
;; --------------------------------------------------
(defun mostrar_erro_movimento (img_key)
  (cond
    ((= img_key "img_a") 
     (destacar_erro_haste "img_a")
     (set_tile "txt_status" "Erro: Movimento inválido na haste A"))
    ((= img_key "img_b") 
     (destacar_erro_haste "img_b")
     (set_tile "txt_status" "Erro: Movimento inválido na haste B"))
    ((= img_key "img_c") 
     (destacar_erro_haste "img_c")
     (set_tile "txt_status" "Erro: Movimento inválido na haste C"))
  )
)

;; --------------------------------------------------
;; Função: DESTACAR_ERRO_HASTE
;; Parâmetros: img_key - nome do tile
;; Descrição: Desenha borda vermelha na haste
;; --------------------------------------------------
(defun destacar_erro_haste (img_key / x y centro_x rect_x1 rect_y1 rect_x2 rect_y2 border_thickness)
  ;; Destaca haste com borda vermelha para erro - POSICIONAMENTO CORRIGIDO
  (setq x (dimx_tile img_key))
  (setq y (dimy_tile img_key))
  (setq centro_x (/ x 2))
  
  ;; ESPESSURA da borda (mais espessa para erro)
  (setq border_thickness 2)
  
  ;; COORDENADAS do retângulo de erro (cobre toda a área visível da haste)
  ;; Margens um pouco menores para borda ser mais visível
  (setq margin_h (fix (/ x 25)))  ; ~6.7% de margem horizontal
  (setq margin_v (fix (/ y 25)))  ; ~6.7% de margem vertical
  
  (setq rect_x1 (+ margin_h (fix (/ border_thickness 2))))
  (setq rect_y1 (+ margin_v (fix (/ border_thickness 2))))
  (setq rect_x2 (- x margin_h (fix (/ border_thickness 2))))
  (setq rect_y2 (- y margin_v (fix (/ border_thickness 2))))
  
  (start_image img_key)
  
  ;; Primeiro remove qualquer borda anterior (se houver)
  ;; Desenha retângulo preto nas bordas
  (fill_image 
    (- rect_x1 border_thickness)
    (- rect_y1 border_thickness)
    (+ (- rect_x2 rect_x1) (* 2 border_thickness))
    border_thickness
    0  ; Preto
  )
  
  (fill_image 
    (- rect_x1 border_thickness)
    rect_y2
    (+ (- rect_x2 rect_x1) (* 2 border_thickness))
    border_thickness
    0  ; Preto
  )
  
  (fill_image 
    (- rect_x1 border_thickness)
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    0  ; Preto
  )
  
  (fill_image 
    rect_x2
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    0  ; Preto
  )
  
  ;; Agora desenha borda VERMELHA
  ;; Linha SUPERIOR
  (fill_image 
    rect_x1
    rect_y1
    (- rect_x2 rect_x1)
    border_thickness
    1  ; Vermelho
  )
  
  ;; Linha INFERIOR
  (fill_image 
    rect_x1
    (- rect_y2 border_thickness)
    (- rect_x2 rect_x1)
    border_thickness
    1  ; Vermelho
  )
  
  ;; Linha ESQUERDA
  (fill_image 
    rect_x1
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    1  ; Vermelho
  )
  
  ;; Linha DIREITA
  (fill_image 
    (- rect_x2 border_thickness)
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    1  ; Vermelho
  )
  
  (end_image)
)
;; --------------------------------------------------
;; Função: REMOVER_ERRO_MOVIMENTO
;; Parâmetros: img_key - nome do tile
;; Descrição: Remove borda vermelha e redesenha haste normal
;; --------------------------------------------------
(defun remover_erro_movimento (img_key / x y centro_x rect_x1 rect_y1 rect_x2 rect_y2 border_thickness)
  ;; Remove o retângulo vermelho - POSICIONAMENTO CORRIGIDO
  (setq x (dimx_tile img_key))
  (setq y (dimy_tile img_key))
  (setq centro_x (/ x 2))
  
  ;; ESPESSURA da borda (igual à usada em destacar_erro_haste)
  (setq border_thickness 3)
  
  ;; COORDENADAS do retângulo (iguais às usadas em destacar_erro_haste)
  (setq margin_h (fix (/ x 25)))
  (setq margin_v (fix (/ y 25)))
  
  (setq rect_x1 (+ margin_h (fix (/ border_thickness 2))))
  (setq rect_y1 (+ margin_v (fix (/ border_thickness 2))))
  (setq rect_x2 (- x margin_h (fix (/ border_thickness 2))))
  (setq rect_y2 (- y margin_v (fix (/ border_thickness 2))))
  
  (start_image img_key)
  
  ;; Remove borda vermelha (desenha preto por cima)
  ;; Linha SUPERIOR
  (fill_image 
    rect_x1
    rect_y1
    (- rect_x2 rect_x1)
    border_thickness
    0  ; Preto
  )
  
  ;; Linha INFERIOR
  (fill_image 
    rect_x1
    (- rect_y2 border_thickness)
    (- rect_x2 rect_x1)
    border_thickness
    0  ; Preto
  )
  
  ;; Linha ESQUERDA
  (fill_image 
    rect_x1
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    0  ; Preto
  )
  
  ;; Linha DIREITA
  (fill_image 
    (- rect_x2 border_thickness)
    rect_y1
    border_thickness
    (- rect_y2 rect_y1)
    0  ; Preto
  )
  
  (end_image)
  
  ;; IMPORTANTE: Redesenha a haste normalmente para restaurar os discos
  (cond
    ((= img_key "img_a") 
     (desenhar_haste_com_discos "img_a" (nth 0 *hastes*) "A"))
    ((= img_key "img_b") 
     (desenhar_haste_com_discos "img_b" (nth 1 *hastes*) "B"))
    ((= img_key "img_c") 
     (desenhar_haste_com_discos "img_c" (nth 2 *hastes*) "C"))
  )
)
;; ============================================
;; FUNÇÕES AUXILIARES
;; ============================================

;; --------------------------------------------------
;; Função: DESENHAR_TODAS_HASTES
;; Descrição: Redesenha todas as 3 hastes
;; --------------------------------------------------
(defun desenhar_todas_hastes ()
  (desenhar_haste_com_discos "img_a" (nth 0 *hastes*) "A")
  (desenhar_haste_com_discos "img_b" (nth 1 *hastes*) "B")
  (desenhar_haste_com_discos "img_c" (nth 2 *hastes*) "C")
)

;; --------------------------------------------------
;; Função: LIMPAR_SELECOES
;; Descrição: Limpa seleções de origem/destino
;; --------------------------------------------------
(defun limpar_selecoes ()
  ;; Limpa todas as seleções
  (setq *origem_selecionada* nil)
  (setq *destino_selecionado* nil)
  
  ;; Remove destaque amarelo das hastes
  (destacar_haste "img_a" nil)
  (destacar_haste "img_b" nil)
  (destacar_haste "img_c" nil)
  
  ;; NÃO remove erros vermelhos aqui - eles devem persistir até nova ação
)
;; --------------------------------------------------
;; Função: LIMPAR_ERRO_SELECAO
;; Parâmetros: key - nome do tile
;; Descrição: Remove erro visual quando seleciona nova origem
;; --------------------------------------------------
(defun limpar_erro_selecao (key)
  (cond
    ((= key "img_a") 
     (if (equal (get_tile "txt_status") "Erro: Movimento inválido na haste A")
       (progn
         (remover_erro_movimento "img_a")
         (set_tile "txt_status" "Pronto...")
       )
     ))
    ((= key "img_b")
     (if (equal (get_tile "txt_status") "Erro: Movimento inválido na haste B")
       (progn
         (remover_erro_movimento "img_b")
         (set_tile "txt_status" "Pronto...")
       )
     ))
    ((= key "img_c")
     (if (equal (get_tile "txt_status") "Erro: Movimento inválido na haste C")
       (progn
         (remover_erro_movimento "img_c")
         (set_tile "txt_status" "Pronto...")
       )
     ))
  )
)

;; --------------------------------------------------
;; Função: ATUALIZAR_HASte
;; Parâmetros: hastes - lista atual de hastes
;;             idx - índice da haste a atualizar
;;             nova_haste - nova lista de discos
;; Descrição: Atualiza uma haste específica na lista
;; --------------------------------------------------
(defun atualizar_haste (hastes idx nova_haste)
  (cond
    ((= idx 0) (cons nova_haste (cdr hastes)))
    ((= idx 1) (list (car hastes) nova_haste (caddr hastes)))
    ((= idx 2) (list (car hastes) (cadr hastes) nova_haste))
  )
)

;; --------------------------------------------------
;; Função: NOME_HASTE
;; Parâmetros: idx - índice da haste
;; Retorna: Nome da haste (A, B ou C)
;; --------------------------------------------------
(defun nome_haste (idx)
  (nth idx '("A" "B" "C"))
)

;; --------------------------------------------------
;; Função: VERIFICAR_VITORIA
;; Descrição: Verifica se jogador completou o jogo
;; --------------------------------------------------
(defun verificar_vitoria ()
  (if (and (null (nth 0 *hastes*))
           (null (nth 1 *hastes*))
           (= (length (nth 2 *hastes*)) *num_discos*))
    (set_tile "txt_status" 
              (strcat "PARABÉNS! Você venceu em " 
                     (itoa *movimentos*) 
                     " movimentos! (Mínimo: " 
                     (itoa (- (expt 2 *num_discos*) 1)) ")"))
  )
)

;; --------------------------------------------------
;; Função: ATUALIZAR_VALOR_SLIDER
;; Parâmetros: valor_str - valor do slider como string
;; Descrição: Atualiza interface quando slider é movido
;; --------------------------------------------------
(defun atualizar_valor_slider (valor_str)
  (set_tile "txt_discos_valor" valor_str)
  (setq n (atoi valor_str))
  (set_tile "txt_minimo" (strcat "Mínimo: " (itoa (- (expt 2 n) 1))))
  (iniciar_jogo)
)

;; --------------------------------------------------
;; Função: INICIAR_JOGO
;; Descrição: Inicia jogo com valor atual do slider
;; --------------------------------------------------
(defun iniciar_jogo ()
  (setq n_str (get_tile "txt_discos_valor"))
  (setq n (atoi n_str))
  (iniciar_jogo_com_discos n)
)

;; --------------------------------------------------
;; Função: RESETAR_JOGO
;; Descrição: Reinicia jogo com mesmo número de discos
;; --------------------------------------------------
(defun resetar_jogo ()
  ;; Reinicia o jogo com o mesmo número de discos
  (if (> *num_discos* 0)
    (iniciar_jogo_com_discos *num_discos*)
    (set_tile "txt_status" "Nenhum jogo para resetar. Use o slider.")
  )
)

(defun inicializar_jogo ()
  ;; Inicialização das seleções
  (setq *origem_selecionada* nil)
  (setq *destino_selecionado* nil)
  (limpar_selecoes)

  ;; Configura slider e valores iniciais
  (mode_tile "#arkz" 1)
  (HN_ShowSld "#img_logo" "Hanoi" "ArkZLogo" -2)
  (HN_ShowSld "sep1" "Hanoi" "Separato" -2)
  (HN_ShowSld "sep2" "Hanoi" "Separato" -2)
  
  (set_tile "slider_discos" "3")
  (set_tile "txt_discos_valor" "3")
  (set_tile "txt_status" "Pronto para começar...")
  (set_tile "txt_movimentos" "Movimentos: 0")
  (set_tile "txt_minimo" "Mínimo: 7")
  
  ;; Inicializa variáveis globais
  (setq *hastes* (list nil nil nil))
  (setq *num_discos* 0)
  (setq *movimentos* 0)
  (setq *historico* nil)
  
  ;; Inicializa fator de escala
  (setq *hanoi_scale_factor* 1.0)
  
  ;; Atualiza textos
  (set_tile "txt_a" "A: 0")
  (set_tile "txt_b" "B: 0")
  (set_tile "txt_c" "C: 0")
  
  ;; Inicia jogo automaticamente com valor padrão (3 discos)
  ;; CALCULA ESCALA ANTES DE DESENHAR
  (calcular_fator_escala "img_a")  ; Usa uma das hastes como referência
  (iniciar_jogo_com_discos 3)
)
;; ============================================
;; ADICIONAR FUNÇÃO DE RECALCULAR ESCALA
;; ============================================
(defun recalcular_escala_todas_hastes ()
  ;; Recalcula escala para todas as hastes (útil se DCL for redimensionado)
  (calcular_fator_escala "img_a")
  (desenhar_todas_hastes)
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
;;; Função Hanoi_Help
(defun Hanoi_help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Hanoi.txt
  (if (not (findfile "Hanoi.txt"))
    (progn
      (alert "O arquivo Hanoi.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Hanoi.dcl"))
               (new_dialog "Hanoi_help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Hanoi.txt"))
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
            (HN_ShowSld "#img_logo" "Hanoi" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Hanoi - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Hanoi.dcl.")
      )
    )
  )
  (princ)
)
;;;

;; ============================================
;; INICIALIZAÇÃO FINAL
;; ============================================

(princ "\nTorre de Hanoi carregado. Digite HANOI para jogar.")
(princ)
