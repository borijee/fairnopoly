#
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
#

module CommendationHelper


  def get_social_producer_questionaire_for question, article
    html = ""
    if article.social_producer_questionnaire.send(question)

      html << "<h5>" + t('formtastic.labels.social_producer_questionnaire.' + question.to_s) + "</h5>"
      html << "<p>" + t('article.show.agree')+ "</p>"

      value = article.social_producer_questionnaire.attributes[question.to_s + "_checkboxes"]
      if value
        html << "<ul>"
        value.each do |purpose|
          html << "<li>" + t('enumerize.social_producer_questionnaire.' + question.to_s +  '_checkboxes.' + purpose) + "</li>"
        end
        html << "</ul>"
      end
    end
    html.html_safe
  end

  def get_fair_trust_questionaire_for question, article
    html = ""
    if article.fair_trust_questionnaire.send(question)

      html << "<h5>" + t('formtastic.labels.fair_trust_questionnaire.' + question.to_s) + "</h5>"
      html << "<p>" + t('article.show.agree')+ "</p>"

      value = article.fair_trust_questionnaire.attributes[question.to_s + "_checkboxes"]
      if value
        html << "<ul>"
        value.each do |purpose|
          html << "<li>" + t('enumerize.fair_trust_questionnaire.' + question.to_s +  '_checkboxes.' + purpose)
          if purpose == "other" && article.fair_trust_questionnaire.send(question.to_s + "_other")
            html << " " + article.fair_trust_questionnaire.send(question.to_s + "_other")
          end
          html << "</li>"
        end
        html << "</ul>"
      end

      html << "<p><b>" + t('formtastic.labels.fair_trust_questionnaire.' + question.to_s +  '_explanation') + "</b></p>"
      html << "<p>" + article.fair_trust_questionnaire.send(question.to_s + "_explanation") + "</p>"
    end
    html.html_safe
  end

  def commendation_labels_for article
    html = ""
    new_window = true
    if article_path(article) == request.path
      link = "#commendation"
      new_window = false
    end
    html << commendation_label(:fair, :small, link, new_window) if article.fair
    html << commendation_label(:ecologic, :small, link, new_window) if article.ecologic
    html << commendation_label(:small_and_precious, :small, link, new_window) if article.small_and_precious
    html << commendation_label(:swappable, :small, nil, new_window) if article.swappable
    html << commendation_label(:borrowable, :small, nil, new_window) if article.borrowable
    html.html_safe
  end


  # Get Labels for the commendations
  #
  # @param label [Symbol] the type of label, `:fair`,`:ecologic`,`:small_and_precious`
  # @param size [Symbol] label size `:small`, `:big`
  # @param link [String] Optional string url where the label should link to
  # @param new_window [Boolean] Optional url in new window?
  #
  def commendation_label label, size , link = nil, new_window = true
    link = commendation_explanation_link label unless link != nil
    html = "<a "
    html << "href=\"#{link}\" " if link
    html << "target=\"_blank\" " if new_window && link
    html << "class=\"#{commendation_label_classes label,size} accordion-anchor\">"
    html << t("article.commendations.#{label.to_s}")
    html << "</a> "
    html.html_safe
  end

  # Get the css classes for a label
  # @param label [Symbol] the type of label, `:fair`,`:ecologic`,`:small_and_precious`
  # @param size [Symbol] Optional label size `:small` ,`:medium`, `:big`
  def commendation_label_classes label, size
     css = "Tag"
     css << case label
     when :fair
       " Tag--blue"
     when :ecologic
       " Tag--green"
     when :small_and_precious
       " Tag--orange"
     when :swappable
       " Tag--gray"
     when :borrowable
       " Tag--gray"
     end
     css << case size
     when :small
       ""
     when :big
       " Tag--big"
     end
     css
  end

  def commendation_explanation_link label
     link = case label
     when :fair
       "/faq#fi3"
     when :ecologic
       "/faq#fi4"
     when :small_and_precious
       "/faq#fi5"
     end
     link
  end


end
