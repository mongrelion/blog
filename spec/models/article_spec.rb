require 'spec_helper'

describe Article do
  describe '#content' do
    describe 'given an existing file' do
      it 'must return a parsed to HTML string' do
        html = '*Example!*'
        File.stub :read, html do
          File.stub :exists?, true do
            Article.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
              parsed_html = RDiscount.new(html).to_html
              article     = Article.find 'example'
              article.content.must_equal parsed_html
            end
          end
        end
      end
    end

    describe 'given a non existent file' do
      it 'must return nil' do
        Article.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
          Article.find('foo-bar-baz').content.must_be_nil
        end
      end
    end
  end

  describe '#spanish' do
    it 'must return articles in spanish' do
      File.stub :read, '' do
        Model.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
          Article.spanish.count.must_equal 1
        end
      end
    end
  end

  describe '#english' do
    it 'must return articles in english' do
      File.stub :read, '' do
        Article.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
          Article.english.count.must_equal 2
        end
      end
    end
  end

  describe '#find' do
    it 'must return nil given an non existing file name' do
      File.stub :read, '' do
        Article.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
          Article.find('i-do-no-exist').must_be_nil
        end
      end
    end

    it 'must find an article given an existing file name' do
      File.stub :read, '' do
        Article.stub :base_dir, File.join(root, 'spec', 'support', 'db') do
          article = Article.find 'foo-bar-baz'
          article.wont_be_nil
          article.file.must_equal 'foo-bar-baz'
          article.title.must_equal 'Foo bar baz'
        end
      end
    end
  end
end
