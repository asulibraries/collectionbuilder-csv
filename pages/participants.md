---
title: Participants
layout: page
permalink: /participants.html
---

## Participants

A full list of participants and the villages they are associated with.

<table class="table table-striped table-bordered">
  <thead>
    <tr>
      <th>Name</th>
      <th>Also Known As</th>
      <th>Village(s)</th>
    </tr>
  </thead>
  <tbody>
    {% for participant in site.data.participants %}
      <tr>
        <td>
          {% if participant.first %}{{ participant.first }} {% endif %}
          {{ participant.last }}
        </td>
        <td>{{ participant.aka }}</td>
        <td>
          {% assign villages = participant.village | default: "" | split: ";" %}
          {% assign printed = false %}
          {% for village in villages %}
            {% assign village_name = village | strip %}
            {% if village_name != "" %}
              {% if printed %}, {% endif %}
              <a href="{{ '/browse.html' | relative_url }}#village:{{ village_name | downcase | uri_escape }}">{{ village_name }}</a>
              {% assign printed = true %}
            {% endif %}
          {% endfor %}
        </td>
      </tr>
    {% endfor %}
  </tbody>
</table>
