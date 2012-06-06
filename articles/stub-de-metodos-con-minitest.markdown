[MiniTest] es una herramienta para pruebas que viene con todos los juguetes
necesarios para nuestro conjunto de pruebas (unitarias, de integración, etc),
soportando TDD, BDD, mocking y benchmarking. Viene por defecto con Ruby 1.9.x
y también está disponible para Ruby 1.8.x.

Provee dos tipos de estilos de pruebas:
*  Test::Unit
*  Spec

Personalmente prefiero el estilo de **Spec**, puesto que este tipo de tests son
más fáciles de leer. Puedes encontrar más información en el la [documentación]
oficial. Si aún no estás usándolo, te recomiendo probarlo. Lo he usado para
escribir tests unitarios, funcionales y de integración y los resultados son
bastante buenos.

Pero bueno, suficiente con la introducción de [MiniTest]. Hablemos ahora de
cómo hacer stub de métodos usando esta herramienta.

Básicamente tenemos dos opciones. La primera es hacer algo como lo que hace
[Aaron Patterson] (a.k.a. [@tenderlove]) en un [screencast] en [PeepCode].
Es algo más o menos así:
<pre>
  <code class="ruby">
    klass = Class.new User do
      define_method(:confirmed?) { true }
    end
    user = klass.new
    user.confirmed?.must_equal true
  </code>
</pre>

Lo que estamos haciendo aquí es redefiniendo la clase **User** y asignando esa
redefinición a la variable **klass**. Dentro de ese bloque de definición también
estamos redefiniento el método de instancia **confirmed?** de esa clase (**User**)
para que cuando lo llamemos, retorne lo que sea que haya dentro del bloque que
le pasamos al método **define_method**, que en este caso es el valor _true_.

La segunda opción que tenemos, la cual es más limpia, elegante, bacanita y menos
compeja es usando el método MiniTest#stub:
<pre>
  <code class="ruby">
    User.stub :confirmed?, true do
      user = User.first
      user.confirmed?.must_equal true
    end
  </code>
</pre>

Claro, preciso y conciso. Esta magia no apareció sino hasta la versión 3.0.0
cuando añadieron el soporte para stubs en este [commit]. Una vez más [MiniTest]
me impresiona por sus increíbles poderes de supervaca (¿o de Gokú?).

  [MiniTest]: http://github.com/seattlerb/minitest
  [documentación]: http://docs.seattlerb.org/minitest/
  [Aaron Patterson]: http://tenderlovemaking.com/
  [@tenderlove]: http://twitter.com/tenderlove
  [PeepCode]: http://peepcode.com
  [screencast]: https://peepcode.com/products/play-by-play-tenderlove-ruby-on-rails
  [commit]: https://github.com/seattlerb/minitest/commit/37e1a04573f1047a1772a21cbfe48823d2c27d7e
