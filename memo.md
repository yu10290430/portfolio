<script type="text/javascript">
  function initMap(){
    let geocoder = new google.maps.Geocoder()
    if(document.getElementById('map')){
      let map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: 35.681236, lng: 139.767125 },
        zoom: 12,
      });
      marker = new google.maps.Marker({
        position: {lat: 35.681236, lng: 139.767125 },
        map: map
      });
    }else{
      let test = {lat: <%= @board.latitude %>, lng: <%= @board.longitude %> };
      let map = new google.maps.Map(document.getElementById('show_map'), {
        zoom: 15,
        center: test
      });
      let transitLayer = new google.maps.TransitLayer();
      transitLayer.setMap(map);
      let contentString = '住所：<%= @board.address %>';
      let infowindow = new google.maps.InfoWindow({
        content: contentString
      });

      let marker = new google.maps.Marker({
        position: test,
        map: map,
        title: contentString
      });

      marker.addListener('click', function() {
        infowindow.open(map, marker);
      });
    }
  }
  function codeAddress(){
    let inputAddress = document.getElementById('address').value;

    map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: 35.681236, lng: 139.767125 },
        zoom: 12,
    });

    geocoder.geocode( { 'address': inputAddress}, function(results, status) {
      if (status == 'OK') {
        map.setCenter(results[0].geometry.location);
        let marker = new google.maps.Marker({
          map: map,
          position: results[0].geometry.location
        });
      }else {
        alert('該当する結果がありませんでした：' + status);
      }
    });
  }
</script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=<%= ENV['GOOGLE_MAP_KEY'] %>&callback=initMap"></script>



<% @boards.each do |board| %>
    <div class="card">
      <div class="card-body">
        <h4 class="card-title">
          <%= link_to board_path(board.id) do %>
            <%= board.title %>
          <% end %>
        </h4>
        <div class='mr10 float-right'>
        </div>
        <ul class="list-inline">
          <%= link_to user_path(board.user_id) do %>
            <li class="list-inline-item">
              <%= image_tag url_for(board.user.avatar), size: '30x30' %>
            </li>
            <li class="list-inline-item">
              <%= board.user.name %>
            </li>
          <% end %>
          <li class="list-inline-item">
            <%= l board.created_at, format: :long  %>
          </li>
        </ul>
        <div class="board_body">
          <div class="text_area">
            <p class="card-text"><%= board.body %></p>
          </div>
          <div class="board_image">
            <% board.images.each do |image| %>
              <%= image_tag url_for(image), size: '150x150' %>
            <% end %>
          </div>
          <div class="address">
            <p>釣り場： <%= board.address %> </p>
          </div>
        </div>
      </div>
    </div>
  <% end %>


<div class="follow_main">
  <div class="row">
    <div class="col-md-3 col-lg-3">
      <div class="left_side_bar">
        <div class="user_information">
          <%= image_tag url_for(@user.avatar), size: '150x150' %>
          <h3><%= user.name %></h3>
        </div>
        <div class="icon_container">
          <div class="icon_box">
            <%= link_to followings_user_path(@user) do %>
              <% if current_page?(followings_user_path) %>
                <p><i class="fa-solid fa-user-check fa-2x" style="color: royalblue;"></i></p>
              <% else %>
                <p><i class="fa-solid fa-user-check fa-2x"></i></p>
              <% end %>
              <p>フォロー中</p>
            <% end %>
          </div>
          <div class="icon_box">
            <%= link_to followers_user_path(@user) do %>
              <% if current_page?(followers_user_path) %>
                <p><i class="fa-solid fa-users fa-2x" style="color: royalblue;"></i></p>
              <% else %>
                <p><i class="fa-solid fa-users fa-2x"></i></p>
              <% end %>
              <p>フォロワー</p>
            <% end %>
          </div>
          <div class="icon_box">
            <%= link_to user_path(@user) do %>
              <p><i class="fa-solid fa-rotate-left fa-2x"></i></p>
              <p>戻る</p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-6 col-lg-6>
      <div class="user_list">
        <%  @follower_users.each do |user| %>
          <div class="card">
            <div class="card-body">
              <div class="user_box">
                <ul class="list-inline">
                  <%= link_to user_path(user.id) do %>
                    <li class="list-inline-item">
                      <%= image_tag url_for(user.avatar), size: '30x30' %>
                    </li>
                    <li class="list-inline-item">
                      <%= user.name %>
                    </li>
                  <% end %>
                  <li class="list-inline-item">
                    <% if current_user.id != user.id %>
                      <%= render 'shared/follow_button', user: user %>
                    <% end %>
                  </li>
                  <li class="introduction">
                    <%= user.introduction %>
                  </li>
                </ul>
            </div>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>


<div class="follow_main">
  <div class="row">
    <%= render 'shared/follow_icon', user: @user %>
    <div class="col-md-6 col-lg-6>
      <div class="user_list">
        <%  @follower_users.each do |user| %>
          <div class="card">
            <div class="card-body">
              <div class="user_box">
                <ul class="list-inline">
                  <%= link_to user_path(user.id) do %>
                    <li class="list-inline-item">
                      <%= image_tag url_for(user.avatar), size: '30x30' %>
                    </li>
                    <li class="list-inline-item">
                      <%= user.name %>
                    </li>
                  <% end %>
                  <li class="list-inline-item">
                    <% if current_user.id != user.id %>
                      <%= render 'shared/follow_button', user: user %>
                    <% end %>
                  </li>
                  <li class="introduction">
                    <%= user.introduction %>
                  </li>
                </ul>
            </div>
          </div>
        <% end %>
      </div>
    </div>
  </div>
</div>
