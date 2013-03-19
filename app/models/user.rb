#encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :phone_number,:name,:number_dreams,:incoming , :outgoing,

  has_many :dreams

  def self.find_for_user(hash,signed_in_resource=nil)

    user = User.where(:phone_number => hash.sender).first  #BUSCAR por Telefone
    

    #criar sessão para ele
    #se não exister o uid em nenhum usuário cadastrar.
    unless user

      user = User.create(  :provider => auth.provider,
                           :uid => auth.uid,
                           :email => auth.info.email,
                           :name =>auth.info.first_name,
                           :lastname =>auth.info.last_name,
                           :password => auth.info.email,
                           :remote_avatar_url => auth.info.image,
                           :facebook => auth.extra.raw_info.link,
                           :rating => 0,
                           :count_rating => 0
                           )
    end
    return user

  end





end