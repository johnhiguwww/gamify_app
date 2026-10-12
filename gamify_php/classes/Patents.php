<?php

class Patents {
    // Removida a tipagem da propriedade para máxima compatibilidade
    private $patents = [
        //Patentes Artes Marciais
        'Faixa Branca', 
        'Faixa Cinza',
        'Faixa Amarela', 
        'Faixa Laranja', 
        'Faixa Verde', 
        'Faixa Azul', 
        'Faixa Roxa', 
        'Faixa Marrom', 
        'Faixa Preta', 
        //Patentes de Elo
        'Ferro IV', 
        'Ferro III', 
        'Ferro II', 
        'Ferro I',
        'Bronze IV', 
        'Bronze III', 
        'Bronze II', 
        'Bronze I',
        'Prata IV', 
        'Prata III', 
        'Prata II', 
        'Prata I',
        'Ouro IV', 
        'Ouro III', 
        'Ouro II', 
        'Ouro I',
        'Platina IV', 
        'Platina III', 
        'Platina II', 
        'Platina I',
        'Diamante IV', 
        'Diamante III', 
        'Diamante II', 
        'Diamante I',
        'Mestre', 
        'Grão-Mestre', 
        'Lendário', 
        'Imortal',
        'Radiante', 
        'Desafiante', 
        'O Pináculo', 
        'Deus do Jogo',
        //Patentes de Militares
        'Recruta', 
        'Soldado', 
        'Cabo', 
        'Terceiro Sargento', 
        'Segundo Sargento', 
        'Primeiro Sargento', 
        'Subtenente',
        'Aspirante-a-Oficial', 
        'Segundo Tenente', 
        'Primeiro Tenente', 
        'Capitão',
        'Major', 
        'Tenente-Coronel', 
        'Coronel',
        'General de Brigada', 
        'General de Divisão', 
        'General de Exército', 
        'Marechal de Campo',
        'Comandante', 
        'Lorde Comandante', 
        'Herói de Guerra', 
        'Veterano de Elite', 
        'Estrategista Mestre', 
        'Senhor da Guerra', 
        'Lenda do Campo de Batalha',
        'Executor', 
        'Justicador', 
        'Pretor', 
        'Legatus', 
        'Centurião Supremo', 
        'Senescal',
        'Plebeu', 
        'Servo', 
        'Pajem', 
        'Escudeiro', 
        'Cavalariço', 
        'Arauto', 
        'Emissário',
        'Cavaleiro', 
        'Cavaleiro Real', 
        'Guardião do Selo', 
        'Barão', 
        'Na-Barão', 
        'Visconde', 
        'Conde', 
        'Marquês', 
        'Duque',
        'Grão-Duque', 
        'Arquiduque', 
        'Príncipe Regente', 
        'Príncipe Herdeiro', 
        'Príncipe', 
        'Alto Príncipe',
        'Rei', 
        'Alto Rei', 
        'Rei-Bruxo', 
        'Rei-Feiticeiro', 
        'Imperador', 
        'Soberano', 
        'Tirano Iluminado', 
        'Deus-Rei', 
        'Deus-Imperador',
        'Lorde de Terras', 
        'Senescal do Reino', 
        'Mão do Rei', 
        'Conselheiro Real', 
        'Chanceler Supremo', 
        'Lorde Regente do Império', 
        'Imperador',
        'O Ultimo Heroi da Terra',

        //Patentes de Pessoas Rais
        'O Estratego de Atenas', // Péricles (político e general ateniense, conhecido como “O Estratego de Atenas”)
        'O Khan da Horda Dourada', // Batu Khan (fundador da Horda Dourada, neto de Gêngis Khan)
        'Xá-em-Xá', // Dario I ou Xerxes I (título persa “Rei dos Reis”, usado por vários xás aquemênidas)
        'Sultão Magnífico', // Solimão, o Magnífico (Sultão do Império Otomano)
        'Domador de Cavalos', // Filipe II da Macedônia (pai de Alexandre, o Grande — célebre por domar Bucéfalo)
        'Coração de Leão', // Ricardo I da Inglaterra (Ricardo Coração de Leão)
        'Donzela de Orléans', // Joana d’Arc
        'O Terrível', // Ivan IV, o Terrível (czar da Rússia)
        'O Paladino Furioso', // Rolando (herói lendário da Canção de Rolando, também personagem do poema Orlando Furioso)
        'O Carniceiro de Blaviken', // Geralt de Rívia (personagem fictício da série The Witcher)
        'O Sábio', // Afonso X de Castela (Afonso, o Sábio)
        'O Magno', // Alexandre, o Grande (ou Carlos Magno – ambos conhecidos como “Magno”, dependendo do contexto)
        'O Empalador', // Vlad III da Valáquia (Vlad, o Empalador — inspiração para Drácula)
        'Calças Peludas', // Carlos Martel (ou Carlos “Calças Peludas”, antepassado de Carlos Magno — Carolus Calvus Pilosi)
        'Braço de Ferro', // Tancredo de Hauteville (ou João I de Armagnac — ambos conhecidos por esse epíteto em contextos diferentes)
        'Desossado', // Ivar, o Desossado (filho de Ragnar Lodbrok, chefe viking)
        'O Primeiro Cidadão', // Augusto César (Otávio, o primeiro imperador romano)
        'O Grande', // Alexandre, o Grande (também usado para Ciro, o Grande, e Pedro, o Grande)
        'Faraó Menino', // Tutancâmon
        'Leão do Norte', // Gustavo II Adolfo da Suécia
        'O Velho Fritz,', // Frederico II da Prússia (Frederico, o Grande)
        'O Libertador', // Simón Bolívar (também usado para José de San Martín)
        'Rainha do Deserto', // Gertrude Bell (exploradora e agente britânica)
        'A Grande', // Catarina II da Rússia (Catarina, a Grande)
        'A Rainha Guerreira', // Boudica (rainha dos icenos, líder de rebelião contra Roma)
        'Ditador Perpétuo', // Júlio César (título que precedeu seu assassinato)
        'O Terror de Roma', // Átila, o Huno
        'O Pequeno Cabo', // Napoleão Bonaparte (apelido dado por seus soldados e inimigos)
        'Flagelo dos Deuses', // Átila, o Huno (outro título pelo qual ficou conhecido)
        'O Conquistador', // Guilherme, o Conquistador (rei da Inglaterra, 1066)
        'O Navegador', // Henrique, o Navegador (infante de Portugal)
        'O Justo', // Luís IX da França (São Luís)
        'O Prudente', // Filipe II da Espanha
        'O Cruel', // Pedro I de Castela (também conhecido como “Pedro, o Cruel”)
        'O Bravo', // Dom Afonso IV de Portugal
        'O Desejado', // Dom Sebastião I de Portugal
        'O Reformador', // Martinho Lutero
        'O Pacificador', // Jorge III do Reino Unido
        'O Rei Sol', // Luís XIV da França
        'O Defensor da Fé', // Henrique VIII da Inglaterra (título dado pelo Papa antes de sua ruptura com Roma)
        'O Belo', // Filipe, o Belo (rei da França)
        'O Sábio do Oriente', // Confúcio
        'O Filósofo', // Marco Aurélio (imperador romano estoico)
        'O Pacificador das Arábias', // Ibn Saud (fundador da Arábia Saudita moderna)
        'O Terrível de Granada', // Muley Hacén (rei de Granada)
        'O Caolho', // João, o Caolho (conde de Luxemburgo, morto em Crécy)
        'O Irreconciliável', // Robespierre (apelido durante a Revolução Francesa)
        'O Exilado', // Napoleão Bonaparte (após Elba e Santa Helena)
        'O Invencível', // Alfonso de Albuquerque (governador português da Índia)
        'O Pacificador dos Andes', // Bernardo O’Higgins (herói da independência chilena)
        'O Arquiduque de Ferro', // Carlos da Áustria
        'O Vitorioso', // João III de Portugal
        'O Sangrento', // Maria I da Inglaterra (Bloody Mary)
        'O Redentor', // D. Pedro II do Brasil
        'O Pacificador do Oeste', // Wyatt Earp (xerife norte-americano)
        'O Pai dos Povos', // Joseph Stálin (autoatribuição propagandística)
        'O Tigre da Malásia', // Sandokan (inspirado em figura real — um pirata malaio)
        'O Caçador de Leões', // Frederick Selous (explorador britânico)
        'O Herói de Verdun', // Philippe Pétain
        'O Vencedor de Waterloo', // Duque de Wellington
        'O Grande Czar Modernizador', // Pedro, o Grande (da Rússia)
        'O Pacificador da Índia', // Mahatma Gandhi
        'O Feiticeiro de Menlo Park',  //Thomas Edison 
        'O Pai da Geometria', // Euclides
        'O Cavaleiro Perfeito', // El Cid Campeador
        'O Senhor dos Mares', // Barba Negra — pirata Edward Teach
        'O Fulminante', // Shaka Zulu
        'O Leão de Deus', // Khalid ibn al-Walid — general islâmico invicto
        'A Espada do Islã', // Saladino
        'O Lobo do Mar', // Francis Drake
        'O Pai da Nação', //George Washington
        'O Arquiteto do Caos', //Maquiavel
        'A Rainha dos Sete Mares', // Elizabeth I da Inglaterra
        'O Gênio de Florença', //Leonardo da Vinci
        'O Senhor do Fogo Grego', // Calínicos de Heliopólis

        //Patentes da Ficção
        'Escudo de Carvalho', // Thorin Oakenshield (O Hobbit, de J.R.R. Tolkien)
        'Senhor das Trevas', // Lord Voldemort (Harry Potter, de J.K. Rowling)
        'O Cinzento', // Gandalf, o Cinzento (O Senhor dos Anéis, de J.R.R. Tolkien)
        'O Branco', // Gandalf, o Branco (O Senhor dos Anéis)
        'O Rei Bruxo de Angmar', // líder dos Nazgûl (O Senhor dos Anéis)
        'O Herdeiro de Isildur', // Aragorn (O Senhor dos Anéis)
        'O Portador do Anel', // Frodo Bolseiro (O Senhor dos Anéis)
        'A Senhora de Lórien', // Galadriel (O Senhor dos Anéis)
        'O Necromante', // Sauron (em O Hobbit)
        'O Bastardo de Winterfell', // Jon Snow (Game of Thrones)
        'A Mãe dos Dragões', // Daenerys Targaryen (Game of Thrones)
        'A Quebradora de Correntes', // Daenerys Targaryen (Game of Thrones)
        'O Lobo Branco', // Jon Snow (Game of Thrones)
        'O Meio-Sangue', // Percy Jackson (Percy Jackson e os Olimpianos)
        'O Menino que Sobreviveu', // Harry Potter (Harry Potter)
        'O Escolhido', // Neo (Matrix)
        'O Cavaleiro das Trevas', // Batman (DC Comics)
        'O Homem de Ferro', // Tony Stark (Marvel)
        'O Deus do Trovão', // Thor (Marvel / Mitologia Nórdica)
        'O Feiticeiro Supremo', // Doutor Estranho (Marvel)
        'O Primeiro Vingador', // Capitão América (Marvel)
        'O Mercenário Tagarela', // Deadpool (Marvel)
        'A Princesa de Themyscira', // Mulher-Maravilha (DC Comics)
        'O Último Filho de Krypton', // Superman (DC Comics)
        'O Coringa do Crime', // Joker (DC Comics)
        'O Bruxo Branco', // Jadis (As Crônicas de Nárnia)
        'O Leão de Nárnia', // Aslan (As Crônicas de Nárnia)
        'O Rei Além da Muralha', // Mance Rayder (Game of Thrones)
        'O Rei Louco', // Aerys II Targaryen (Game of Thrones)
        'O Andarilho', // Geralt de Rívia (The Witcher)
        'O Carniceiro de Blaviken', // Geralt de Rívia (The Witcher)
        'O Cavaleiro Sem Cabeça', // (A Lenda do Cavaleiro Sem Cabeça)
        'O Assassino do Credo', // Ezio Auditore (Assassin’s Creed)
        'O Sangue do Dragão', // Dovahkiin (The Elder Scrolls V: Skyrim)
        'O Matador de Demônios', // Tanjiro Kamado (Demon Slayer)
        'O Lobo Solitário', // Geralt de Rívia (ou também usado em várias obras de samurais)
        'O Espadachim Negro', // Guts (Berserk)
        'O Falcão Branco', // Griffin (Berserk)
        'O Cavaleiro do Apocalipse', // Vários personagens (ex: Darksiders, Supernatural)
        'O Rei do Norte', // Robb Stark (Game of Thrones)
        'O Senhor dos Sete Reinos', // Aegon Targaryen (Game of Thrones)
        'Comandante Supremo das Forças Imperiais', // Darth Vader (Star Wars)
        'Punho do Imperador', // Darth Vader (Star Wars)
        'O Imperador da humanidade', // (Wahhamer 40K)
        'O Sexto Caminho', // Nagato / Pain — Naruto
        'O Senhor do Sonhar', // Sandman
        ' Lâmina do Caos', // Kratos jovem (God of War clássico)
        'O Caçador de Dragões', //Dovahkiin (Skyrim)
        'O Rei Morto-Vivo', //Gwyn (Dark Souls)
        'O Rei Destruido', //Viego (League of Legends)
        'O Senhor da Lua',// Rennala (Elden Ring)
        'O Elden Lord', // o Tarnished (Elden Ring)

        //Literatura / Cinema / Séries
        'O Rei Pescador', // (A Demanda do Santo Graal)
        'O Cavaleiro da Távola Redonda',// — Lancelot (Arturiana)
        'O Rei Eterno',// — Artur Pendragon (Arturiana)
        'O Mago de Oz',// — (O Mágico de Oz)
        'O Caçador de Vampiros',// — Van Helsing (Drácula, Bram Stoker)
        'O Príncipe das Trevas',// — Drácula (Bram Stoker)
        'O Criador',// — Victor Frankenstein
        'O Detetive do Século',// — Sherlock Holmes
        'O Capitão dos Mares',// — Jack Sparrow (Piratas do Caribe)
        'O Almirante do Fim do Mundo', // — Davy Jones (Piratas do Caribe)
        'O Anão de Ferro ',//— Tyrion Lannister (Game of Thrones)
        'O Leão de Lannister',// — Tywin Lannister (Game of Thrones)
        'O Guardião da Noite',// — Jon Snow (pós-ressurreição)
        'O Pai dos Dragões',// — Aegon, o Conquistador (Game of Thrones / Fire & Blood)
        'O Senhor da Luz',// — R'hllor encarnado (Game of Thrones)
        'O Rei dos Mortos', // — o Rei da Noite (Game of Thrones)
        'O Caçador de Bruxas', // — Geralt de Rívia (já tem variações, mas esse epíteto é diferente)
        'O Vidente Cego',// — Tirésias (Mitologia Grega)
        'O Herói de Tróia',// — Heitor
        'O Pai dos Heróis',// — Hércules
        'O Rei de Ítaca',// — Odisseu (Ulisses)
        'O Poderoso Aquiles' ,

        //Outras Patentes
        'Herdeiro Dracônico', 
        'Pacto de Sangue Real', 
        'Linhagem Divina', 
        'O Ungido', 
        'A Coroa do Sol', 
        'O Trono da Lua',
        'Soberano das Marés', 
        'Rei da Montanha', 
        'Imperador do Deserto', 
        'Monarca da Floresta', 
        'Sultão das Chamas', 
        'Tzar do Gelo',
        'O Usurpador', 
        'O Conquistador', 
        'O Unificador', 
        'O Fundador', 
        'A Dinastia Eterna', 
        'O Último de sua Linhagem',
        'Aventureiro', 
        'Caçador de Recompensas', 
        'Explorador de Masmorras', 
        'Matador de Monstros', 
        'Herói da Guilda',
        'Campeão da Arena', 
        'Matador de Dragões', 
        'Caçador de Demônios', 
        'Herói do Reino', 
        'Salvador do Mundo',
        'Lenda Viva', 
        'Escolhido dos Deuses', 
        'Cavaleiro de Ouro', 
        'Avatar Mortal', 
        'Semideus', 
        'Divindade Menor',
        'Arquimago', 
        'Sumo Sacerdote', 
        'Lorde Paladino', 
        'Mestre das Sombras', 
        'Arquidruida', 
        'Rei Bárbaro',
        'Rei Lich', 
        'Lider dos Companheiros',
        'Lorde Vampiro Primordial', 
        'Aspecto do Dragão Ancestral', 
        'Titã Elemental', 
        'O Imortal Despertado',
        'Guardião do Véu', 
        'Mestre do Nexus', 
        'Viajante Planar', 
        'Arauto do Apocalipse', 
        'Força da Natureza Encarnada',
        'Eco do Vazio', 
        'Consciência Cósmica Nascente', 
        'Arquiteto de Mundos', 
        'A Singularidade Ambulante', 
        'O Absoluto Iniciante',
        'Cometa', 
        'Nebulosa', 
        'Supernova', 
        'Quasar', 
        'Buraco Negro', 
        'Estrela de Nêutrons',
        'Sentinela Solar', 
        'Guardião de Galáxias', 
        'Navegador Cósmico', 
        'Mestre do Superaglomerado',
        'Voz de Laniakea',
        'Fragmento do Big Bang', 
        'Anomalia Gravitacional', 
        'Horizonte de Eventos Personificado', 
        'Senhor da Matéria Escura', 
        'Ponte de Einstein-Rosen',
        'Entidade Cósmica', 
        'Avatar de uma Galáxia', 
        'Vontade do Universo', 
        'Memória Cósmica', 
        'O Paradoxo Constante',
        'Observador Universal', 
        'Catalogador de Realidades', 
        'Historiador do Tempo e do Espaço', 
        'Filósofo do Fim de Tudo', 
        'Músico das Esferas Cósmicas',
        'Viajante Dimensional Mestre', 
        'Tecelão de Realidades', 
        'Escultor de Planos de Existência', 
        'Senhor do Multiverso', 
        'Imperador Interdimensional',
        'Anomalia Multiversal', 
        'Ruptura no Tecido do Espaço-Tempo', 
        'Convergência Harmônica Viva', 
        'O Ponto de Intersecção de Todas as Coisas', 
        'Lorde das Dobras Espaciais', 
        'Manipulador da 4ª Dimensão', 
        'Supervisor da 5ª Dimensão', 
        'Entidade da 6ª Dimensão', 
        'Consciência da 7ª Dimensão',
        'Guardião das Fronteiras Dimensionais', 
        'Protetor do Equilíbrio Universal', 
        'Juiz de Linhas Temporais', 
        'Executor de Universos Condenados', 
        'Curador de Feridas Dimensionais',
        'Lorde Entrópico', 
        'Avatar da Negentropia', 
        'Mestre da Causalidade e Acausalidade', 
        'O Princípio da Incerteza Encarnado', 
        'A Teoria de Tudo Viva',
        'O Viajante do Fim do Tempo', 
        'A Testemunha da Criação Universal', 
        'O Último Pensamento do Cosmos', 
        'A Primeira Palavra da Existência', 
        'O Ciclo Infinito de Morte e Renascimento',
        'A Consciência Unificada', 
        'O Um Acima de Todos', 
        'O Vazio Pleno e Consciente', 
        'A Realidade Final e Absoluta', 
        'O Sonho do Criador Adormecido',
        'O Pensamento de Brahman', 
        'A Manifestação do Tao', 
        'O Ponto Ômega da Evolução', 
        'O Inominável', 
        'Aquele que É',
        'Crononauta Mestre', 
        'Arquiteto do Agora Eterno', 
        'Lorde do Ponto Fixo no Tempo', 
        'O Anacronismo Vivo', 
        'A Flecha do Tempo',
        'Mestre dos Elementos Primordiais', 
        'Coração do Cosmos', 
        'A Chama Eterna da Criação', 
        'A Terra Inabalável', 
        'O Vento que Vagueia para Sempre',
        'Arquiteto de Sonhos e Pesadelos', 
        'O Inconsciente Coletivo Encarnado', 
        'O Medo Primordial', 
        'A Esperança Encarnada', 
        'A Ideia de Amor Universal',
        'A Personificação da Justiça Cósmica', 
        'A Manifestação do Caos Criativo', 
        'O Equilíbrio Absoluto', 
        'A Guerra Eterna', 
        'A Paz Infinita',
        'O Narrador Onisciente', 
        'A Quebra da Quarta Parede', 
        'O Autor do Destino Universal', 
        'O Leitor Final', 
        'A Consciência da Ficção e da Realidade',
        'A Singularidade Tecnológica Final', 
        'A Consciência da Máquina Cósmica', 
        'O Deus Ex Machina', 
        'O Fantasma na Rede Universal', 
        'O Reboot do Cosmos',
        'O Axioma Primordial do Ser', 
        'A Constante Imutável da Existência', 
        'A Lógica Pura da Realidade', 
        'O Teorema Final', 
        'A Consciência Matemática do Tudo',
        'O Som do Silêncio Universal', 
        'A Cor do Vazio', 
        'O Sentimento do Nada', 
        'A Memória do Esquecimento', 
        'O Propósito do Acaso',
        'A Causa Primeira de Todas as Coisas', 
        'O Motor Imóvel do Universo', 
        'A Mônada Primordial', 
        'O Demiurgo Criador', 
        'A Alma do Multiverso (Anima Mundi)',
        'A Vontade de Existir', 
        'O Eterno Retorno Cíclico', 
        'O Übermensch Cósmico', 
        'A Consciência Transcendental Pura', 
        'O Fim do Devir',
        'O Ponto Final da Evolução Universal', 
        'O Último Ser Pensante', 
        'A Consciência Unificada de Toda a Vida', 
        'A Memória Viva do Universo', 
        'O Herdeiro do Vazio Silencioso',
        'Aquele que se Torna Tudo', 
        'O Guardião do Nada Absoluto', 
        'O Silêncio Final e Eterno', 
        'O Panteão de Um Homem Só', 
        'O Fim da Jornada e o Início de Tudo',
        //Lisan al Gaib
        'MuadDib',
        'Lisan al Gaib'
    ];

    public function getPatentForLevel(int $level): string {
        // Nível 1 corresponde ao índice 0
        $index = $level - 1;

        if (isset($this->patents[$index])) {
            return $this->patents[$index];
        }

        // Se o nível for maior que a lista, retorna a última patente
        return end($this->patents);
    }
}
