Cuando finalmente decidí sacar un blog, le dí una merecida oportunidad a Jekyll
y a Octopress. Tienen buenos plugins, las estrategias para desplegar a producción
son "fáciles" y tal, pero de alguna manera, no me sentía a gusto. Ahí fue cuando
decidí escribir mi propia vaina. al fin y al cabo, soy "developero" y construir
mi propia solución no debería ser tan complicado.  
La solución que me "inventé" fue inspirada en el sitio personal de [@cyx], aunque
ahora mismo estoy pensando seriamente en refactorizar un par de cosas por aquí y por allá.

Primero lo primero: No soy un diseñador talentoso.  
Aunque me sentía satisfecho con el último diseño que me inventé para el sitio, aun
sentía que algo estaba mal.  
¡[Twitter Bootstrap] al rescate! Ha estado en el mercado ya por un buen tiempo.
Lo he usado antes en un par de proyectos. Estoy acostumbrado a usarlo. El diseño
es bacanito. Es responsive, bla, bla, bla. Hay un par de efectos de sombras que
le agregué al siti para hacer que se vea un poco más bacanito y un poco más "original".

También estuve probando [Mina] para desplegar el sutio a mi VPS.
Al igual que con [Capistrano], con [Mina] se pueden correr comandos del lado del
servidor además de poder meterle trucos de magia con Ruby. Hasta viene con soporte
incluído para [Bundler], [Foreman], [Git], [Rails], [Rake], [rbenv] (¡yupi!), [rvm]
y [Whenever].  
Debido a que [Capistrano] ha estado en el mercado por mucho más tiempo, hay mucha
más documentación y recursos para leer, aunque la documentación de [Mina] es muy
elegante (para no decir que le patea las nalgas a la docu de Capistrano), lo que
hace más fácil empezar a usar que con [Capistrano], que en mi opinión da un poco
de miedo [#hatersgonnahate].  
También cabe mencionar que la actvidad de desarrollo de [Capistrano](https://github.com/capistrano/capistrano/commits/master)
parece estar un poco más activa que la de [Mina](https://github.com/nadarei/mina/commits/master).

Otro cambio que le hice al sitio fue cambiar de [Thin] a [Puma]. Me salté la parte
de hacer algunos benchmarks. Lo siento. Lo bueno es que este cambio ya está en
producción. Sí, este sitio está siendo servido por [Nginx] + [Puma] con [ruby 2.0.0-p0]

También estoy pensando en servir mi sitio con SSL pero no estoy seguro si es
completamente necesario o si vale la pena en lo absoluto, pero podría llegar a ser
divertido y entretenido. Algo he de aprender. Si me pueden sugerir un proveedor
**gratis** de certificados SSL, por favor, déjenme un comentario.

Por último, no por ello menos importante, el cambio más grande que tengo pensado
para el sitio es precargar todos los artículos en memoria.  
Cuando comencé a construir el sitio, alguien en IRC me hizo caer en cuenta que
escribimos estos blogs en puro texto plano (suena obvio, ¿cierto?) pero si miramos
más allá de lo obvio, nos damos cuenta que escribir blog posts no es algo que yo hago
a diario, y tampoco es algo que creo que vaya a alcanzar el primer terabyte de escritos
en las próximas dos décadas.  
Con esto en mente, necesito decidir si cargar en memoria los artículos precompilados
(escribo los artículos en markdown y los parseo usando [RDiscount]), ya que las
etiquetas HTML y los espacios extra pueden ocupar algo más de memoria, o
compilarlos/parsearlos "en caliente", pero precompilarlos me suena más porque
puedo obtener un mejor performance del sitio puesto que no tendría que parsear
el markdown por cada una de las veces que llega una solicitud al servidor.

De cualquier manera, si tienen alguna sugerencia, soy todo oídos (u ojos en este caso).

Publicaré otro post con las actualizaciones que le haga a este sitio mío.

[Jekyll]: http://jekyllrb.com
[Octopress]: http://octopress.org
[@cyx]: https://github.com/cyx/cyrildavid.com
[Twitter Bootstrap]: http://twitter.github.com/bootstrap
[Mina]: http://nadarei.co/mina
[Capistrano]: http://capify.org
[#hatersgonnahate]: https://twitter.com/search?q=%23hatersgonnahate&src=typd
[built-in support]: https://github.com/nadarei/mina/tree/master/lib/mina
[Bundler]: http://gembundler.com
[Foreman]: http://ddollar.github.com/foreman
[Git]: http://git-scm.com
[Rake]: http://rake.rubyforge.org
[Rails]: http://rubyonrails.org
[rbenv]: https://github.com/sstephenson/rbenv
[rvm]: https://rvm.io
[Whenever]: https://github.com/javan/whenever
[Thin]: http://code.macournoyer.com/thin/
[Puma]: http://puma.io
[Nginx]: http://wiki.nginx.org
[ruby 2.0.0-p0]: http://www.ruby-lang.org/en/news/2013/02/24/ruby-2-0-0-p0-is-released/
[RDiscount]: https://github.com/rtomayko/rdiscount
